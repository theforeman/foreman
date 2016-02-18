class Feature < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  has_and_belongs_to_many :smart_proxies
  validates_lengths_from_database
  validates :name, :presence => true
  validates :priority, :presence => true

  default_scope -> { order(:priority) }

  MAX_PRIORITY = 99999

  def self.name_map
    Feature.all.inject({}) do |ret_val, feature|
      ret_val[feature.name.downcase.gsub(/\s+/, "")] = feature.name
      ret_val
    end
  end

  # Features are sorted on their priority value
  def <=>(other)
    if (!(self.priority.present? && other.priority.present?)) || (self.priority == other.priority)
      self.name <=> other.name
    else
      self.priority <=> other.priority
    end
  end
end
