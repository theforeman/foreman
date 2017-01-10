class Filter < ActiveRecord::Base
  include Taxonomix
  include Authorizable

  attr_writer :resource_type
  attr_accessor :unlimited

  class ScopedSearchValidator < ActiveModel::Validator
    def validate(record)
      resource_class = record.resource_class
      resource_class.search_for(record.search) unless (resource_class.nil? || record.search.nil?)
    rescue ScopedSearch::Exception => e
      record.errors.add(:search, _("invalid search query: %s") % e)
    end
  end

  # tune up taxonomix for filters, we don't want to set current taxonomy
  def add_current_organization?
    false
  end

  def add_current_location?
    false
  end

  def ensure_taxonomies_not_escalated
    super if skip_taxonomy_escalation_check?
  end

  def skip_taxonomy_escalation_check?
    if self.resource_class.present?
      !self.resource_class.included_modules.include?(Taxonomix)
    else
      true
    end
  end

  belongs_to :role
  has_many :filterings, :autosave => true, :dependent => :destroy
  has_many :permissions, :through => :filterings

  validates_lengths_from_database

  default_scope -> { order(["#{self.table_name}.role_id", "#{self.table_name}.id"]) }
  scope :unlimited, -> { where(:search => nil, :taxonomy_search => nil) }
  scope :limited, -> { where("search IS NOT NULL OR taxonomy_search IS NOT NULL") }

  scoped_search :on => :search, :complete_value => true
  scoped_search :on => :override, :complete_value => { :true => true, :false => false }
  scoped_search :on => :limited, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_limited, :only_explicit => true
  scoped_search :on => :unlimited, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_unlimited, :only_explicit => true
  scoped_search :relation => :role, :on => :id, :rename => :role_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :relation => :role, :on => :name, :rename => :role
  scoped_search :relation => :permissions, :on => :resource_type, :rename => :resource
  scoped_search :relation => :permissions, :on => :name,          :rename => :permission

  before_validation :build_taxonomy_search, :nilify_empty_searches, :enforce_override_flag
  before_save :enforce_inherited_taxonomies

  validates :search, :presence => true, :unless => Proc.new { |o| o.search.nil? }
  validates_with ScopedSearchValidator
  validates :role, :presence => true

  validate :role_not_locked
  before_destroy :role_not_locked

  validate :same_resource_type_permissions, :not_empty_permissions, :allowed_taxonomies

  def self.search_by_unlimited(key, operator, value)
    search_by_limited(key, operator, value == 'true' ? 'false' : 'true')
  end

  def self.search_by_limited(key, operator, value)
    value      = value == 'true'
    value      = !value if operator == '<>'
    conditions = value ? 'search IS NOT NULL OR taxonomy_search IS NOT NULL' : 'search IS NULL AND taxonomy_search IS NULL'
    { :conditions => conditions }
  end

  # This method attempts to return an existing class that is derived from the resource_type.
  # In some instances, this may not be a real class (e.g. a typo) or may be nil in the case
  # of a filter not having been saved yet and thus the permissions objects not being currently
  # accessible.
  def self.get_resource_class(resource_type)
    return nil if resource_type.nil?
    resource_type.constantize
  rescue NameError => e
    Foreman::Logging.exception("unknown class #{resource_type}, ignoring", e)
    return nil
  end

  def unlimited?
    search.nil? && taxonomy_search.nil?
  end

  def limited?
    !unlimited?
  end

  def to_s
    _('filter for %s role') % self.role.try(:name) || 'unknown'
  end

  def resource_type
    type = @resource_type || filterings.first.try(:permission).try(:resource_type)
    type.blank? ? nil : type
  end

  def resource_class
    @resource_class ||= self.class.get_resource_class(resource_type)
  end

  # We detect granularity by inclusion of Authorizable module and scoped_search definition
  # we can define exceptions for resources with more complex hierarchy (e.g. Host is proxy module)
  def granular?
    @granular ||= begin
      return false if resource_class.nil?
      return true if resource_type == 'Host'
      resource_class.included_modules.include?(Authorizable) && resource_class.respond_to?(:search_for)
    end
  end

  def allows_taxonomies_filtering?
    allows_organization_filtering? || allows_location_filtering?
  end

  def allows_organization_filtering?
    granular? && resource_class.allows_organization_filtering?
  end

  def allows_location_filtering?
    granular? && resource_class.allows_location_filtering?
  end

  def search_condition
    searches = [self.search]
    searches << self.taxonomy_search if Taxonomy.enabled_taxonomies.any?
    searches.compact!
    searches.map! { |s| parenthesize(s) } if searches.size > 1
    searches.join(' and ')
  end

  def expire_topbar_cache(sweeper)
    role.users.each      { |u| u.expire_topbar_cache(sweeper) }
    role.usergroups.each { |g| g.expire_topbar_cache(sweeper) }
  end

  def disable_overriding!
    self.override = false
    self.save!
  end

  def enforce_inherited_taxonomies
    inherit_taxonomies! unless self.override?
  end

  def inherit_taxonomies!
    self.organization_ids = self.role.organization_ids if self.allows_organization_filtering?
    self.location_ids = self.role.location_ids if self.allows_location_filtering?
    build_taxonomy_search
  end

  private

  def build_taxonomy_search
    orgs = build_taxonomy_search_string('organization')
    locs = build_taxonomy_search_string('location')

    orgs = [] if !granular? || !resource_class.allows_organization_filtering?
    locs = [] if !granular? || !resource_class.allows_location_filtering?

    if self.organizations.empty? && self.locations.empty?
      self.taxonomy_search = nil
    else
      taxonomies = [orgs, locs].reject {|t| t.blank? }
      self.taxonomy_search = taxonomies.join(' and ')
    end
  end

  def build_taxonomy_search_string(name)
    relation = name.pluralize
    taxes = self.send(relation).empty? ? [] : self.send(relation).map { |t| "#{name}_id = #{t.id}" }
    taxes = taxes.join(' or ')
    parenthesize(taxes)
  end

  def nilify_empty_searches
    self.search = nil if self.search.empty? || self.unlimited == '1'
    self.taxonomy_search = nil if self.taxonomy_search.empty?
  end

  def parenthesize(string)
    if string.blank? || (string.start_with?('(') && string.end_with?(')'))
      string
    else
      "(#{string})"
    end
  end

  # if we have 0 types, empty validation will set error, we can't have more than one type
  def same_resource_type_permissions
    errors.add(:permissions, _('Permissions must be of same resource type')) if self.permissions.map(&:resource_type).uniq.size > 1
  end

  def not_empty_permissions
    errors.add(:permissions, _('You must select at least one permission')) if self.permissions.blank? && self.filterings.blank?
  end

  def allowed_taxonomies
    if self.organization_ids.present? && !self.allows_organization_filtering?
      errors.add(:organization_ids, _('You can\'t assign organizations to this resource'))
    end

    if self.location_ids.present? && !self.allows_location_filtering?
      errors.add(:location_ids, _('You can\'t assign locations to this resource'))
    end
  end

  def enforce_override_flag
    self.override = false unless self.allows_taxonomies_filtering?
    true
  end

  def role_not_locked
    errors.add(:role_id, _('is locked for user modifications.')) if role.locked? && !role.modify_locked
    errors.empty?
  end
end
