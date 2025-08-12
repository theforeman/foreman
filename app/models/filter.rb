class Filter < ApplicationRecord
  audited :associated_with => :role

  include Authorizable
  include TopbarCacheExpiry

  attr_writer :resource_type

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

  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :on => :search, :complete_value => true
  scoped_search :relation => :role, :on => :id, :rename => :role_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :relation => :role, :on => :name, :rename => :role
  scoped_search :relation => :permissions, :on => :resource_type, :rename => :resource
  scoped_search :relation => :permissions, :on => :name,          :rename => :permission

  before_validation :nilify_empty_searches
  before_save :enforce_inherited_taxonomies, :nilify_empty_searches

  validates :search, :presence => true, :unless => proc { |o| o.search.nil? }
  validates_with ScopedSearchValidator
  validates :role, :presence => true

  validate :role_not_locked
  before_destroy :role_not_locked

  validate :same_resource_type_permissions, :not_empty_permissions

  def self.allows_taxonomy_filtering?(_taxonomy)
    false
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

  def resource_taxable?
    resource_taxable_by_organization? || resource_taxable_by_location?
  end

  def resource_taxable_by_organization?
    granular? && resource_class.allows_organization_filtering?
  end

  def resource_taxable_by_location?
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

  def enforce_inherited_taxonomies
    organization_ids = role.organization_ids if resource_taxable_by_organization?
    location_ids = role.location_ids if resource_taxable_by_location?
    build_taxonomy_search(organization_ids, location_ids)
  end

  private

  def build_taxonomy_search(organization_ids, location_ids)
    orgs = build_taxonomy_search_string_from_ids('organization', organization_ids)
    locs = build_taxonomy_search_string_from_ids('location', location_ids)

    taxonomies = [orgs, locs].reject { |t| t.blank? }
    self.taxonomy_search = taxonomies.join(' and ').presence
  end

  def build_taxonomy_search_string_from_ids(name, ids)
    return '' if ids.empty?
    parenthesize("#{name}_id ^ (#{ids.join(',')})")
  end

  def nilify_empty_searches
    self.search = nil if search.empty?
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
    types = permissions.map(&:resource_type).uniq
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

  def role_not_locked
    errors.add(:role_id, _('is locked for user modifications.')) if role.locked? && !role.modify_locked
    errors.empty?
  end
end
