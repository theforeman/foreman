#TODO: remove this when there is a gem or a fix for rails that validates nested attributes correctly
module ParameterValidators
  extend ActiveSupport::Concern

  included do
    validate :validate_lookup_value_matchers
  end

  def validate_lookup_value_matchers
    errors = false
    if lookup_values.present?
      lookup_values.select(&:new_record?).group_by(&:lookup_key_id).values.each do |value_list|
        if value_list.count > 1
          self.lookup_values.detect { |nlv| nlv.id == value_list.last.id }.errors[:match] = _('has already been taken')
          errors = true
        end
      end
      self.errors[:lookup_values_attributes] = _('Please ensure the following matchers are unique') if errors
    end
    errors
  end
end
