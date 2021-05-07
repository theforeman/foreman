module ForemanChef
  class FactImporter < ::StructuredFactImporter
    class FactNameImportError < StandardError; end

    def fact_name_class
      ForemanChef::FactName
    end

    def self.authorized_smart_proxy_features
      'Chef'
    end

    def self.support_background
      true
    end

    class Sparser
      def sparse(hash, options = {})
        hash.map do |k, v|
          prefix = (options.fetch(:prefix, []) + [k])
          next sparse(v, options.merge(:prefix => prefix)) if v.is_a? Hash
          { prefix.join(options.fetch(:separator, FactName::SEPARATOR)) => v }
        end.reduce(:merge) || {}
      end

      def unsparse(hash, options = {})
        ret = {}
        sparse(hash).each do |k, v|
          current            = ret
          key                = k.to_s.split(options.fetch(:separator, FactName::SEPARATOR))
          current            = (current[key.shift] ||= {}) until (key.size <= 1)
          current[key.first] = v
        end
        ret
      end
    end
  end
end
