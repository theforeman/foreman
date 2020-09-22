class Filter < ApplicationRecord
  audited :associated_with => :role

  include Taxonomix
  include Authorizable
  include TopbarCacheExpiry

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

  # allow creating filters for non-taxable resources when user is not admin
  def ensure_taxonomies_not_escalated
  end

  belongs_to :role
  has_many :filterings, :autosave => true, :dependent => :destroy
  has_many :permissions, :through => :filterings

  validates_lengths_from_database

  default_scope -> { order(["#{table_name}.role_id", "#{table_name}.id"]) }
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
  before_save :enforce_inherited_taxonomies, :nilify_empty_searches

  validates :search, :presence => true, :unless => proc { |o| o.search.nil? }
  validates_with ScopedSearchValidator
  validates :role, :presence => true

  validate :role_not_locked
  before_destroy :role_not_locked

  validate :same_resource_type_permissions, :not_empty_permissions, :allowed_taxonomies

  def self.search_by_unlimited(key, operator, value)
    search_by_limited(key, operator, (value == 'true') ? 'false' : 'true')
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
    nil
  end

  def unlimited?
    search.nil? && taxonomy_search.nil?
  end

  def limited?
    !unlimited?
  end

  def to_s
    _('filter for %s role') % role.try(:name) || 'unknown'
  end

  def to_label
    permissions.pluck(:name).to_sentence
  end

  def resource_type
    type = @resource_type || filterings.first.try(:permission).try(:resource_type)
    type.presence
  end

  def resource_type_label
    resource_class.try(:humanize_class_name) || resource_type || N_('(Miscellaneous)')
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
    searches = [search]
    searches << taxonomy_search
    searches.compact!
    searches.map! { |s| parenthesize(s) } if searches.size > 1
    searches.join(' and ')
  end

  def expire_topbar_cache
    role.users.each      { |u| u.expire_topbar_cache }
    role.usergroups.each { |g| g.expire_topbar_cache }
  end

  def disable_overriding!
    self.override = false
    save!
  end

  def enforce_inherited_taxonomies
    inherit_taxonomies! unless override?
  end

  def inherit_taxonomies!
    self.organization_ids = role.organization_ids if allows_organization_filtering?
    self.location_ids = role.location_ids if allows_location_filtering?
    build_taxonomy_search
  end

  private

  def build_taxonomy_search
    orgs = build_taxonomy_search_string('organization')
    locs = build_taxonomy_search_string('location')

    orgs = [] if !granular? || !resource_class.allows_organization_filtering?
    locs = [] if !granular? || !resource_class.allows_location_filtering?

    if organizations.empty? && locations.empty?
      self.taxonomy_search = nil
    else
      taxonomies = [orgs, locs].reject { |t| t.blank? }
      self.taxonomy_search = taxonomies.join(' and ')
    end
  end

  def build_taxonomy_search_string(name)
    relation = send(name.pluralize).pluck(:id)
    return '' if relation.empty?

    parenthesize("#{name}_id ^ (#{relation.join(',')})")
  end

  def nilify_empty_searches
    self.search = nil if search.empty? || unlimited == '1'
    self.taxonomy_search = nil if taxonomy_search.empty?
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
    # Performance/ChainArrayAllocation
    types = permissions.map(&:resource_type)
    types.uniq!
    if types.size > 1
      errors.add(
        :permissions,
        _('must be of same resource type (%{types}) - Role (%{role})') %
        {
          types: types.join(','),
          role: role.name,
        }
      )
    end
  end

  def not_empty_permissions
    errors.add(:permissions, _('You must select at least one permission')) if permissions.blank? && filterings.blank?
  end

  def allowed_taxonomies
    if organization_ids.present? && !allows_organization_filtering?
      errors.add(:organization_ids, _('You can\'t assign organizations to this resource'))
    end

    if location_ids.present? && !allows_location_filtering?
      errors.add(:location_ids, _('You can\'t assign locations to this resource'))
    end
  end

  def enforce_override_flag
    self.override = false unless allows_taxonomies_filtering?
    true
  end

  def role_not_locked
    errors.add(:role_id, _('is locked for user modifications.')) if role.locked? && !role.modify_locked
    errors.empty?
  end
end
