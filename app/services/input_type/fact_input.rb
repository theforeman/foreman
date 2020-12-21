module InputType
  class FactInput < Base
    class Resolver < Base::Resolver
      # fact might not be present if it hasn't been uploaded yet, there's typo in name
      def ready?
        @scope.host && get_fact.present?
      end

      def resolved_value
        get_fact.value
      end

      private

      def get_fact
        @fact ||= @scope.host.fact_values.includes(:fact_name).find_by(:'fact_names.name' => @input.fact_name)
      end
    end

    def self.humanized_name
      _('Fact value')
    end

    attributes :fact_name

    def validate(input)
      input.errors.add(:fact_name, :blank) if input.fact_name.blank?
    end
  end
end
