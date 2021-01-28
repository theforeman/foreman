module InputType
  class PuppetParameterInput < Base
    class Resolver < Base::Resolver
      def ready?
        @scope.host &&
          get_enc.key?(@input.puppet_class_name) &&
          get_enc[@input.puppet_class_name].is_a?(Hash) &&
          get_enc[@input.puppet_class_name].key?(@input.puppet_parameter_name)
      end

      def resolved_value
        get_enc[@input.puppet_class_name][@input.puppet_parameter_name]
      end

      private

      def get_enc
        @enc ||= HostInfoProviders::PuppetInfo.new(@scope.host).puppetclass_parameters
      end
    end

    def self.humanized_name
      _('Puppet parameter')
    end

    attributes :puppet_class_name, :puppet_parameter_name

    def validate(input)
      input.errors.add(:puppet_class_name, :blank) if input.puppet_class_name.blank?
      input.errors.add(:puppet_parameter_name, :blank) if input.puppet_parameter_name.blank?
    end
  end
end
