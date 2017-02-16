class Feature < ApplicationRecord
  extend FriendlyId
  friendly_id :name
  has_and_belongs_to_many :smart_proxies
  has_many :smart_proxy_pools, :through => :smart_proxies, :source => 'pools'
  validates_lengths_from_database
  validates :name, :presence => true

  def self.name_map
    Feature.all.each_with_object({}) do |feature, ret_val|
      ret_val[feature.name.downcase.gsub(/\s+/, "")] = feature.name
    end
  end
end
