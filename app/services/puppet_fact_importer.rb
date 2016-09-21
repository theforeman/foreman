class PuppetFactImporter < StructuredFactImporter
  def self.authorized_smart_proxy_features
    'Puppet'.freeze
  end

  def fact_name_class
    PuppetFactName
  end
end
