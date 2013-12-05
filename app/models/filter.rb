class Filter < ActiveRecord::Base
  include Taxonomix

  attr_accessible :search, :resource_type, :permission_ids, :role_id, :unlimited,
                  :organization_ids, :location_ids
  attr_writer :resource_type, :unlimited

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
    permission = self.permissions.first
    permission.nil? ? nil : permission.resource_type
  end

end
