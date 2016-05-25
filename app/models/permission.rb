class Permission < ActiveRecord::Base
  attr_accessible :name, :resource_type

  validates_lengths_from_database
  validates :name, :presence => true, :uniqueness => true

  has_many :filterings, :dependent => :destroy
  has_many :filters, :through => :filterings

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :resource_type

  def self.resources
    @all_resources ||= Permission.order(:resource_type).pluck(:resource_type).compact.map { |r| r.delete("'") }.uniq
  end

  def self.resources_with_translations
    with_translations.sort { |a, b| a.first <=> b.first }
  end

  def self.with_translations
    resources.map { |r| [_(Filter.get_resource_class(r).try(:humanize_class_name) || r), r] }
  end

  def self.reset_resources
    @all_resources = nil
  end
end
