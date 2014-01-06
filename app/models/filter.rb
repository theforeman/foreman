class Filter < ActiveRecord::Base
  include Taxonomix

  attr_accessible :search, :resource_type, :permission_ids, :role_id, :unlimited,
                  :organization_ids, :location_ids
  attr_writer :resource_type
  attr_accessor :unlimited

  belongs_to :role
  has_many :filterings
  has_many :permissions, :through => :filterings

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda { with_taxonomy_scope }

  scope :unlimited, lambda { where(:search => nil) }
  scope :limited, lambda { where("search IS NOT NULL") }

  scoped_search :on => :search, :complete_value => true
  scoped_search :in => :role, :on => :id, :rename => :role
  scoped_search :in => :role, :on => :name, :rename => :role_name
  scoped_search :in => :permissions, :on => :resource_type, :rename => :resource

  before_validation :set_unlimited_filter, :if => Proc.new { |o| o.unlimited == '1' }

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

  def granular?
    @granular ||= !resource_class.nil? && resource_class.included_modules.include?(Authorizable) && resource_class.respond_to?(:search_for)
  end

  private

  def set_unlimited_filter
    self.search = nil
  end

end
