class Feature < ActiveRecord::Base
  has_and_belongs_to_many :smart_proxies
  validates :name, :presence => true

  NAME_MAP =
    Feature.all.inject({}) do |ret_val, feature|
      ret_val[feature.name.downcase.gsub(" ", "")] = feature.name
      ret_val
    end
end
