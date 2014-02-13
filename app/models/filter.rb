class Filter < ActiveRecord::Base
  include Taxonomix
  include Authorizable

  # tune up taxonomix for filters, we don't want to set current taxonomy
  def self.add_current_organization?
    false
  end

  def self.add_current_location?
    false
  end

  attr_accessible :search, :resource_type, :permission_ids, :role_id, :unlimited,
                  :organization_ids, :location_ids
  attr_writer :resource_type
  attr_accessor :unlimited

  belongs_to :role
  has_many :filterings, :dependent => :destroy
  has_many :permissions, :through => :filterings

  scope :unlimited, lambda { where(:search => nil, :taxonomy_search => nil) }
  scope :limited, lambda { where("search IS NOT NULL OR taxonomy_search IS NOT NULL") }

  scoped_search :on => :search, :complete_value => true
  scoped_search :in => :role, :on => :id, :rename => :role_id
  scoped_search :in => :role, :on => :name, :rename => :role
  scoped_search :in => :permissions, :on => :resource_type, :rename => :resource

  before_validation :build_taxonomy_search, :nilify_empty_searches

  validates :search, :presence => true, :unless => Proc.new { |o| o.search.nil? }
  validates :role, :presence => true
  validate :same_resource_type_permissions, :not_empty_permissions


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
    @resource_class ||= resource_type.constantize
  rescue NameError => e
    Rails.logger.debug "unknown klass #{resource_type}, ignoring"
    return nil
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

  def search_condition
    searches = [self.search, self.taxonomy_search].compact
    searches = searches.map { |s| parenthize(s) } if searches.size > 1
    searches.join(' and ')
  end

  private

  def build_taxonomy_search
    orgs = build_taxonomy_search_string('organization')
    locs = build_taxonomy_search_string('location')

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
    parenthize(taxes)
  end

  def nilify_empty_searches
    self.search = nil if self.search.empty? || self.unlimited == '1'
    self.taxonomy_search = nil if self.taxonomy_search.empty?
  end

  def parenthize(string)
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

end
