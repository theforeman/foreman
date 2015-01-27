class PuppetFactImporter < FactImporter
  def self.authorized_smart_proxy_features
    'Puppet'
  end

  def fact_name_class
    ::FactName
  end
end
