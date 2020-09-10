module ValidateOsFamily
  extend ActiveSupport::Concern

  module ClassMethods
    def validate_inclusion_in_families(family_attr_name)
      validates family_attr_name,
        :inclusion => {
          :in => Operatingsystem.families,
          :message => N_("must be one of [ %s ]" % Operatingsystem.families.join(", ")),
        },
        :allow_nil => true

      define_method "#{family_attr_name}=" do |value|
        self[family_attr_name] = value.presence
      end
    end
  end
end
