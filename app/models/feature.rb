class Feature < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :smart_proxy_features, :dependent => :destroy
  has_many :smart_proxies, :through => :smart_proxy_features

  validates_lengths_from_database
  validates :name, :presence => true, :uniqueness => true

  def self.name_map
    Feature.all.each_with_object({}) do |feature, ret_val|
      ret_val[feature.name.downcase.gsub(/\s+/, "")] = feature
    end
  end
end
