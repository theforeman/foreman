class Permission < ActiveRecord::Base
  attr_accessible :name, :resource_type

  validates :name, :presence => true, :uniqueness => { :scope => :resource_type }

  has_many :filterings
  has_many :filters, :through => :filterings

  def self.resources
    @all_resources ||= Permission.uniq.order(:resource_type).pluck(:resource_type).compact
  end
end
