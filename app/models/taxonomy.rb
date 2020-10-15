class Taxonomy < ApplicationRecord
  validates_lengths_from_database

  include Authorizable
  include NestedAncestryCommon
  include TopbarCacheExpiry

  serialize :ignore_types, Array

  before_create :assign_default_templates
  after_create :assign_taxonomy_to_user
  before_validation :sanitize_ignored_types

  has_many :taxable_taxonomies, :dependent => :destroy
  has_many :users, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'User'
  has_many :smart_proxies, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'SmartProxy'
  has_many :compute_resources, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ComputeResource'
  has_many :media, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Medium'
  has_many :provisioning_templates, -> { where(:type => 'ProvisioningTemplate') }, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ProvisioningTemplate'
  has_many :ptables, -> { where(:type => 'Ptable') }, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Ptable'
  has_many :report_templates, -> { where(:type => 'ReportTemplate') }, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ReportTemplate'
  has_many :domains, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Domain'
  has_many :http_proxies, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'HttpProxy'
  has_many :realms, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Realm'
  has_many :hostgroups, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Hostgroup'
  has_many :subnets, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Subnet'
  has_many :auth_sources, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'AuthSource'

  validate :check_for_orphans, :unless => proc { |t| t.new_record? }
  # the condition for parent_id != 0 is required because of our tests, should validate macros fill in attribute with values and it set 0 to this one
  # which would lead to an error when we ask for parent object
  validate :parent_id_does_not_escalate, :if => proc { |t| t.ancestry_changed? && t.parent_id != 0 && t.parent.present? }
  validates :name, :presence => true, :uniqueness => {:scope => [:ancestry, :type], :case_sensitive => false}

  def self.inherited(child)
    child.instance_eval do
      scoped_search :on => :description, :complete_enabled => :false, :only_explicit => true
      scoped_search :on => :id, :validator => ScopedSearch::Validators::INTEGER

      apipie :class, desc: "A class representing #{model_name.human} object" do
        sections only: %w[all additional]
        name_exl, title_exl = class_scope.model_name.human == 'Location' ? ['Europe', 'Europe/Prague'] : ['Red Hat', 'Red Hat/Engineering']
        prop_group :basic_model_props, ApplicationRecord, meta: { example: name_exl }
        property :title, String, desc: "Title of the #{class_scope}. Comparing to the Name, Title contains also names of all parent #{class_scope}s, e.g. #{title_exl}"
        property :description, String, desc: "Description of the #{class_scope}"
        property :created_at, String, desc: "The time when the #{class_scope} was created"
        property :updated_at, String, desc: "The last time when the #{class_scope} was updated"
      end
      jail_class = Class.new(::Safemode::Jail) do
        allow :id, :name, :title, :created_at, :updated_at, :description
      end
      child.const_set('Jail', jail_class)
    end
    child.send(:include, NestedAncestryCommon::Search)
    super
  end

  delegate :import_missing_ids, :inherited_ids, :used_and_selected_or_inherited_ids, :selected_or_inherited_ids,
    :non_inherited_ids, :used_or_inherited_ids, :used_ids, :to => :tax_host

  default_scope -> { order(:title) }

  scope :completer_scope, lambda { |opts|
    if opts[:controller] == 'organizations'
      Organization.completer_scope opts
    elsif opts[:controller] == 'locations'
      Location.completer_scope opts
    end
  }

  def self.no_taxonomy_scope
    as_taxonomy nil, nil do
      yield if block_given?
    end
  end

  def self.as_taxonomy(org, location)
    Organization.as_org org do
      Location.as_location location do
        yield if block_given?
      end
    end
  end

  def self.types
    [Organization, Location]
  end

  def self.ignore?(taxable_type)
    current_taxonomies = if current.nil? && User.current.present?
                           # "Any context" - all available taxonomies"
                           User.current.public_send("my_#{to_s.underscore.pluralize}")
                         else
                           [current]
                         end
    current_taxonomies.compact.any? do |current|
      current.ignore?(taxable_type)
    end
  end

  # if taxonomy e.g. organization was not set by current context (e.g. Any organization)
  # then we have to compute what this context mean for current user (what organizations
  # they are assigned to)
  #
  # if user is not assigned to any organization then empty relation is returned.
  #
  # if user is admin we we return the original value (even if nil).
  def self.expand(value)
    if value.blank? && User.current.present? && !User.current.admin?
      value = send("my_#{to_s.underscore.pluralize}")
    end
    value
  end

  def ignore?(taxable_type)
    ignore_types.include?(taxable_type.classify)
  end

  def self.all_import_missing_ids
    all.find_each do |taxonomy|
      taxonomy.import_missing_ids
    end
  end

  def self.all_mismatcheds
    includes(:hosts).map { |taxonomy| taxonomy.mismatches }
  end

  def dup
    new = super
    new.name = ""
    new.users             = users
    new.smart_proxies     = smart_proxies
    new.subnets           = subnets
    new.compute_resources = compute_resources
    new.provisioning_templates = provisioning_templates
    new.ptables = ptables
    new.report_templates = report_templates
    new.media             = media
    new.domains           = domains
    new.realms            = realms
    new.media             = media
    new.hostgroups        = hostgroups
    new.auth_sources      = auth_sources
    new
  end

  # overwrite *_ids since need to check if ignored? - don't overwrite location_ids and organization_ids since these aren't ignored
  (TaxHost::HASH_KEYS - [:location_ids, :organization_ids]).each do |key|
    # def domain_ids
    #  if ignore?("Domain")
    #   Domain.pluck(:id)
    # else
    #   super()  # self.domain_ids
    # end
    define_method(key) do
      klass = hash_key_to_class(key)
      if ignore?(klass)
        return User.unscoped.except_admin.except_hidden.map(&:id) if klass == "User"
        return klass.constantize.pluck(:id)
      else
        super()
      end
    end
  end

  def expire_topbar_cache
    (users + User.only_admin).each { |u| u.expire_topbar_cache }
  end

  def parent_params(include_source = false)
    hash = {}
    elements = parents_with_params
    elements.each do |el|
      el.send("#{type.downcase}_parameters".to_sym).authorized(:view_params).each do |p|
        hash[p.name] = include_source ? p.hash_for_include_source(sti_name, el.title) : p.value
      end
    end
    hash
  end

  # returns self and parent parameters as a hash
  def parameters(include_source = false)
    hash = parent_params(include_source)
    send("#{type.downcase}_parameters".to_sym).authorized(:view_params).each do |p|
      hash[p.name] = include_source ? p.hash_for_include_source(sti_name, el.title) : p.value
    end
    hash
  end

  def parents_with_params
    self.class.sort_by_ancestry(self.class.includes("#{type.downcase}_parameters".to_sym).find(ancestor_ids))
  end

  def taxonomy_inherited_params_objects
    # need to pull out the locations to ensure they are sorted first,
    # otherwise we might be overwriting the hash in the wrong order.
    parents = parents_with_params
    parents_parameters = []
    parents.each do |parent|
      parents_parameters << parent.send("#{parent.type.downcase}_parameters".to_sym)
    end
    parents_parameters
  end

  def params_objects
    (send("#{type.downcase}_parameters".to_sym).authorized(:view_params) + taxonomy_inherited_params_objects.to_a.reverse!).uniq { |param| param.name }
  end

  def notification_recipients_ids
    subtree.flat_map(&:users).map(&:id).uniq
  end

  # note - this method used by before_destroy callbacks in extension files from plugins
  # audits for 'destroy' action on resources lead to taxable_taxonomies records.
  # This will check if any taxable_taxonomies records present and apply destroy_all
  # so that it nullifies all associated audit records
  def destroy_taxable_taxonomies
    TaxableTaxonomy.where(taxonomy_id: id).destroy_all
  end

  private

  delegate :need_to_be_selected_ids, :selected_ids, :used_and_selected_ids, :mismatches, :missing_ids, :check_for_orphans,
    :to => :tax_host

  def assign_default_templates
    Template.where(:default => true).group_by { |t| t.class.to_s.underscore.pluralize }.each do |association, templates|
      send("#{association}=", send(association) + templates.select(&:valid?))
    end
  end

  def sanitize_ignored_types
    self.ignore_types ||= []
    self.ignore_types = self.ignore_types.compact.uniq - ["0"]
  end

  def tax_host
    @tax_host ||= TaxHost.new(self)
  end

  def hash_key_to_class(key)
    key.to_s.gsub(/_ids?\Z/, '').classify
  end

  def assign_taxonomy_to_user
    return if User.current.nil? || User.current.admin
    TaxableTaxonomy.create(:taxonomy_id => id, :taxable_id => User.current.id, :taxable_type => 'User')
  end

  def parent_id_does_not_escalate
    unless User.current.can?("edit_#{self.class.to_s.underscore.pluralize}", parent)
      errors.add :parent_id, _("Missing a permission to edit parent %s") % self.class.to_s
      false
    end
  end
end
