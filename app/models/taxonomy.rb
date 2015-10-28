class Taxonomy < ActiveRecord::Base
  include Authorizable

  include NestedAncestryCommon

  serialize :ignore_types, Array

  attr_accessible :name,
        :title,
        :environment_ids,
        :hostgroup_ids,
        :subnet_ids,
        :domain_ids,
        :medium_ids,
        :user_ids,
        :users,
        :smart_proxy_ids,
        :config_template_ids,
        :provisioning_template_ids,
        :compute_resource_ids,
        :location_ids,
        :organization_ids,
        :description,
        :ignore_types

  validates_lengths_from_database
  belongs_to :user
  before_destroy EnsureNotUsedBy.new(:hosts)
  after_create :assign_taxonomy_to_user

  has_many :taxable_taxonomies, :dependent => :destroy
  has_many :users, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'User'
  has_many :smart_proxies, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'SmartProxy'
  has_many :compute_resources, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ComputeResource'
  has_many :media, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Medium'
  has_many :provisioning_templates, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ProvisioningTemplate'
  has_many :ptables, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Ptable'
  has_many :domains, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Domain'
  has_many :realms, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Realm'
  has_many :hostgroups, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Hostgroup'
  has_many :environments, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Environment'
  has_many :subnets, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Subnet'

  validate :check_for_orphans, :unless => Proc.new {|t| t.new_record?}

  validates :name, :presence => true, :uniqueness => {:scope => [:ancestry, :type], :case_sensitive => false}
  validates :title, :presence => true, :uniqueness => {:scope => :type}

  before_validation :sanitize_ignored_types
  after_create :assign_default_templates

  scoped_search :on => :description, :complete_enabled => :false, :only_explicit => true

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
    Array.wrap(self.current).each do |current|
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
    new.provisioning_templates  = provisioning_templates
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
    #   self.taxable_taxonomies.where(:taxable_type => "Domain").pluck(:taxable_id)
    # end
    define_method(key) do
      klass = hash_key_to_class(key)
      if ignore?(klass)
        return User.unscoped.except_admin.except_hidden.map(&:id) if klass == "User"
        return klass.constantize.pluck(:id)
      else
        taxable_taxonomies.where(:taxable_type => klass).pluck(:taxable_id)
      end
    end
  end

  def expire_topbar_cache(sweeper)
    (users+User.only_admin).each { |u| u.expire_topbar_cache(sweeper) }
  end

  # returns self and parent parameters as a hash
  def parameters(include_source = false)
    hash = {}
    ids = ancestor_ids
    ids << id unless new_record? or self.frozen?
    # need to pull out the locations to ensure they are sorted first,
    # otherwise we might be overwriting the hash in the wrong order.
    elements = ids.size == 1 ? [self] : self.class.sort_by_ancestry(self.class.includes("#{type.downcase}_parameters".to_sym).find(ids))
    elements.each do |el|
      el.send("#{type.downcase}_parameters".to_sym).each {|p| hash[p.name] = include_source ? {:value => p.value, :source => sti_name, :safe_value => p.safe_value, :source_name => el.title} : p.value }
    end
    hash
  end

  private

  delegate :need_to_be_selected_ids, :selected_ids, :used_and_selected_ids, :mismatches, :missing_ids, :check_for_orphans,
           :to => :tax_host

  def assign_default_templates
    Template.where(:default => true).each do |template|
      self.send("#{template.class.to_s.underscore.pluralize}") << template
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
