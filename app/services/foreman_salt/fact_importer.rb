module ForemanSalt
  class FactImporter < ::StructuredFactImporter
    def fact_name_class
      ForemanSalt::FactName
    end

    def self.support_background
      true
    end

    def self.authorized_smart_proxy_features
      'Salt'
    end
  end
end
