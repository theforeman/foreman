class Filter < ActiveRecord::Base
  include Taxonomix

  attr_accessible :search, :resource_type, :permission_ids, :role_id, :unlimited,
                  :organization_ids, :location_ids
  attr_writer :resource_type
  attr_accessor :unlimited

  belongs_to :role
  has_many :filterings, :dependent => :destroy
  has_many :permissions, :through => :filterings

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda { with_taxonomy_scope }

  scope :unlimited, lambda { where(:search => nil) }
  scope :limited, lambda { where("search IS NOT NULL") }

  scoped_search :on => :search, :complete_value => true
  scoped_search :in => :role, :on => :id, :rename => :role_id
  scoped_search :in => :role, :on => :name, :rename => :role
  scoped_search :in => :permissions, :on => :resource_type, :rename => :resource

  before_validation :set_unlimited_filter, :if => Proc.new { |o| o.unlimited == '1' }

  validates :search, :presence => true, :unless => Proc.new { |o| o.search.nil? }

  def unlimited?
    search.nil?
  end

  def limited?
    !unlimited?
  end

  def to_s
    _('filter for %s role') % self.role.try(:name) || 'unknown'
  end

  def resource_type
    @resource_type ||= permissions.first.try(:resource_type)
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

  private

  def set_unlimited_filter
    self.search = nil
  end

end
