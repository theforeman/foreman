class Permission < ActiveRecord::Base
  attr_accessible :name, :resource_type

  validates :name, :presence => true, :uniqueness => { :scope => :resource_type }

  has_many :filterings, :dependent => :destroy
  has_many :filters, :through => :filterings

  def self.resources
    @all_resources ||= Permission.uniq.order(:resource_type).pluck(:resource_type).compact
  end

  def self.resources_with_translations
    with_translations.sort { |a, b| a.first <=> b.first }
  end

  def self.with_translations
    resources.map { |r| [_(r), r] }
  end
end
