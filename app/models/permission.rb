class Permission < ActiveRecord::Base
  attr_accessible :name, :resource_type

  validates :name, :presence => true, :uniqueness => { :scope => :resource_type }

  has_many :filterings, :dependent => :destroy
  has_many :filters, :through => :filterings

  def self.resources
    @all_resources ||= Permission.order(:resource_type).pluck(:resource_type).compact.map { |r| r.delete("'") }.uniq
  end

  def self.resources_with_translations
    with_translations.sort { |a, b| a.first <=> b.first }
  end

  def self.with_translations
    resources.map { |r| [_(Filter.get_resource_class(r).try(:humanize_class_name) || r), r] }
  end
end
