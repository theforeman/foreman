class Filter < ActiveRecord::Base
  include Taxonomix
  include Authorizable

  attr_writer :resource_type
  attr_accessor :unlimited
  attr_accessible :search, :unlimited, :resource_type, :permissions,
    :permission_ids, :permission_names, :role_id

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

  belongs_to :role
  has_many :filterings, :dependent => :destroy
  has_many :permissions, :through => :filterings

  validates_lengths_from_database

  default_scope -> { order(["#{self.table_name}.role_id", "#{self.table_name}.id"]) }
  scope :unlimited, -> { where(:search => nil, :taxonomy_search => nil) }
  scope :limited, -> { where("search IS NOT NULL OR taxonomy_search IS NOT NULL") }

  scoped_search :on => :search, :complete_value => true
  scoped_search :on => :limited, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_limited, :only_explicit => true
  scoped_search :on => :unlimited, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_unlimited, :only_explicit => true
  scoped_search :in => :role, :on => :id, :rename => :role_id, :complete_enabled => false, :only_explicit => true
  scoped_search :in => :role, :on => :name, :rename => :role
  scoped_search :in => :permissions, :on => :resource_type, :rename => :resource
  scoped_search :in => :permissions, :on => :name,          :rename => :permission

  before_validation :build_taxonomy_search, :nilify_empty_searches, :fix_to_current_user_permissions

  validates :search, :presence => true, :unless => Proc.new { |o| o.search.nil? }
  validates_with ScopedSearchValidator
  validates :role, :presence => true
  validate :same_resource_type_permissions, :not_empty_permissions, :allowed_taxonomies

  def self.search_by_unlimited(key, operator, value)
    search_by_limited(key, operator, value == 'true' ? 'false' : 'true')
  end

  def self.search_by_limited(key, operator, value)
    value      = value == 'true'
    value      = !value if operator == '<>'
    conditions = value ? limited.where_values.join(' AND ') : unlimited.where_values.map(&:to_sql).join(' AND ')
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
    type = @resource_type || permissions.first.try(:resource_type)
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

  def fix_to_current_user_permissions
    user = User.current
    return unless role_id && user
    return if permission_ids.empty? || user.admin?

    current_filters = user.filters.includes(:permissions).where(
      :permissions => {
        :resource_type => resource_type,
        :id => permissions.map(&:id)}).to_a
    new_permissions = permissions
    new_resource_type = resource_type

    if current_filters.empty?
      errors.add(:resource_type, (_('Current user is not allowed to resource type: %s') % new_resource_type))
      return
    end

    current_search = current_filters.map(&:search).uniq
    if current_search.count > 1
      errors.add(:permission_ids, _('These permissions are restricted by different filters'))
      return
    end
    current_search = current_search.first

    # allow adding filters to permitted resources only
    allowed_permissions =  new_permissions & current_filters.map(&:permissions).flatten
    self.permission_ids = allowed_permissions.map(&:id)

    # restrict filter condition if the user has custom filter:
    # compare the filters using scoped search tokenizer, to avoid whitespace/syntax differences
    new_search_tokens = ScopedSearch::QueryLanguage::Compiler.tokenize search || ''
    if current_search
      self.unlimited = 0
      current_search_tokens = ScopedSearch::QueryLanguage::Compiler.tokenize(current_search)
      unless search == current_search
        #self.search can be 0: '' 1: 'new_condition' 2:'current_condition and (new_condition)'
        current_condition = current_search
        if search.empty?
          # just copy my search [0]
          self.search = current_condition
          # check if the new condition does not begin with old one (not augmented)
        elsif new_search_tokens.take(current_search_tokens.size) != current_search_tokens
          current_condition << " and ("
          self.search = "#{current_condition}#{self.search})"
        end
      end
    end
  end
end
