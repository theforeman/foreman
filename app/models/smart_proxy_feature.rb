class SmartProxyFeature < ApplicationRecord
  belongs_to :smart_proxy
  belongs_to :feature
  validates :feature, :uniqueness => {:scope => :smart_proxy_id}

  serialize :capabilities, Array
  store :settings, coder: JSON

  def details
    {settings: settings, capabilities: capabilities}
  end

  def self.import_features(smart_proxy, features_json)
    name_map = Feature.name_map
    new_feature_classes = features_json.keys.map { |feature| name_map[feature] }
    smart_proxy.smart_proxy_features.where.not(feature: new_feature_classes).destroy_all
    features_json.each do |name, feature_json|
      feature_class = name_map[name]
      # loop through smart_proxy_features to handle unsaved objects
      smart_proxy_feature = smart_proxy.smart_proxy_features.to_a.find { |spf| spf.feature_id == feature_class.id }
      smart_proxy_feature ||= SmartProxyFeature.new(:feature_id => feature_class.id)
      smart_proxy_feature.import_json(feature_json)
      smart_proxy.smart_proxy_features << smart_proxy_feature
    end
  end

  def import_json(feature_json)
    self.capabilities = feature_json[:capabilities]
    self.settings = feature_json[:settings]
  end
end
