class Feature < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  has_and_belongs_to_many :smart_proxies
  validates_lengths_from_database
  validates :name, :presence => true

  def self.name_map
    Feature.all.inject({}) do |ret_val, feature|
      ret_val[feature.name.downcase.gsub(/\s+/, "")] = feature.name
      ret_val
    end
  end

end
