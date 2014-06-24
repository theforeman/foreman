class Feature < ActiveRecord::Base
  has_and_belongs_to_many :smart_proxies
  validates :name, :presence => true

  def self.name_map 
    Feature.all.inject({}) do |ret_val, feature|
      ret_val[feature.name.downcase.gsub(/\s+/, "")] = feature.name
      ret_val
    end
  end

end
