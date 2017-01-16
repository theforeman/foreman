class Taxonomy < ActiveRecord::Base
  validates_lengths_from_database

  include Authorizable
  include NestedAncestryCommon

  serialize :ignore_types, Array

  belongs_to :user
  after_create :assign_taxonomy_to_user

  has_many :taxable_taxonomies, :dependent => :destroy
  has_many :users, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'User'
  has_many :smart_proxies, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'SmartProxy'
  has_many :compute_resources, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ComputeResource'
  has_many :media, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Medium'
  has_many :provisioning_templates, -> { where(:type => 'ProvisioningTemplate') }, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Template'
  has_many :ptables, -> { where(:type => 'Ptable') }, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Template'
  has_many :domains, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Domain'
  has_many :realms, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Realm'
  has_many :hostgroups, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Hostgroup'
  has_many :environments, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Environment'
  has_many :subnets, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Subnet'

  validate :check_for_orphans, :unless => Proc.new {|t| t.new_record?}

  validates :name, :presence => true, :uniqueness => {:scope => [:ancestry, :type], :case_sensitive => false}

  before_validation :sanitize_ignored_types
  after_create :assign_default_templates

  def self.inherited(child)
    child.instance_eval do
      scoped_search :on => :description, :complete_enabled => :false, :only_explicit => true
      scoped_search :on => :id, :validator => ScopedSearch::Validators::INTEGER
    end
    child.send(:include, NestedAncestryCommon::Search)
    super
  end

  delegate :import_missing_ids, :inherited_ids, :used_and_selected_or_inherited_ids, :selected_or_inherited_ids,
           :non_inherited_ids, :used_or_inherited_ids, :used_ids, :to => :tax_host

  default_scope -> { order(:title) }

  scope :completer_scope, lambda{|opts|
    if opts[:controller] == 'organizations'
      Organization.completer_scope opts
    elsif opts[:controller] == 'locations'
      Location.completer_scope opts
    end
  }

  def self.locations_enabled
    enabled?(:location)
  end

  def self.organizations_enabled
    enabled?(:organization)
  end

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

  def self.enabled?(taxonomy)
    case taxonomy
      when :organization
        SETTINGS[:organizations_enabled]
      when :location
        SETTINGS[:locations_enabled]
      else
        raise ArgumentError, "unknown taxonomy #{taxonomy}"
    end
  end

  def self.enabled_taxonomies
    %w(locations organizations).select { |taxonomy| SETTINGS["#{taxonomy}_enabled".to_sym] }
  end

  def self.ignore?(taxable_type)
    current_taxonomies = if self.current.nil? && User.current.present?
                           # "Any context" - all available taxonomies"
                           User.current.public_send(self.to_s.underscore.pluralize)
                         else
                           self.current
                         end
    Array.wrap(current_taxonomies).each do |current|
      return true if current.ignore?(taxable_type)
    end
    false
  end

  # if taxonomy e.g. organization was not set by current context (e.g. Any organization)
  # then we have to compute what this context mean for current user (in what organizations
  # is he assigned to)
  #
  # if user is not assigned to any organization then empty array is returned which means
  # that we should use all organizations
  #
  # if user is admin we we return the original value since it does not need any additional scoping
  def self.expand(value)
    if value.blank? && User.current.present? && !User.current.admin?
      value = self.send("my_#{self.to_s.underscore.pluralize}").all
    end
    value
  end

  def ignore?(taxable_type)
    if ignore_types.empty?
      false
    else
      ignore_types.include?(taxable_type.classify)
    end
  end

  def self.all_import_missing_ids
    all.each do |taxonomy|
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
    new.environments      = environments
    new.smart_proxies     = smart_proxies
    new.subnets           = subnets
    new.compute_resources = compute_resources
    new.provisioning_templates = provisioning_templates
    new.media             = media
    new.domains           = domains
    new.realms            = realms
    new.media             = media
    new.hostgroups        = hostgroups
    new
  end

  # overwrite *_ids since need to check if ignored? - don't overwrite location_ids and organizations_ids since these aren't ignored
  (TaxHost::HASH_KEYS - [:location_ids, :organizations_ids]).each do |key|
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

  def expire_topbar_cache(sweeper)
    (users+User.only_admin).each { |u| u.expire_topbar_cache(sweeper) }
  end

  def parent_params(include_source = false)
    hash = {}
    elements = parents_with_params
    elements.each do |el|
      el.send("#{type.downcase}_parameters".to_sym).authorized(:view_params).each {|p| hash[p.name] = include_source ? {:value => p.value, :source => sti_name, :safe_value => p.safe_value, :source_name => el.title} : p.value }
    end
    hash
  end

  # returns self and parent parameters as a hash
  def parameters(include_source = false)
    hash = parent_params(include_source)
    self.send("#{type.downcase}_parameters".to_sym).authorized(:view_params).each {|p| hash[p.name] = include_source ? {:value => p.value, :source => sti_name, :safe_value => p.safe_value, :source_name => el.title} : p.value }
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
    (self.send("#{type.downcase}_parameters".to_sym).authorized(:view_params) + taxonomy_inherited_params_objects.to_a.reverse!).uniq {|param| param.name}
  end

  private

  delegate :need_to_be_selected_ids, :selected_ids, :used_and_selected_ids, :mismatches, :missing_ids, :check_for_orphans,
           :to => :tax_host

  def assign_default_templates
    Template.where(:default => true).each do |template|
      self.send((template.class.to_s.underscore.pluralize).to_s) << template
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
    TaxableTaxonomy.create(:taxonomy_id => self.id, :taxable_id => User.current.id, :taxable_type => 'User')
  end
end
