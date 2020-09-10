module ParameterValidations
  extend ActiveSupport::Concern
  included do
    should validate_presence_of(parameter_class)
    should validate_presence_of(:name)
    should validate_uniqueness_of(:name).scoped_to(:reference_id)
    should belong_to(parameter_class).with_foreign_key(:reference_id)
    should_not allow_value('   a new param').for(:name)
    should allow_value('   ').for(:value)
    should allow_value('   some crazy \"\'&<*%# value').for(:value)
  end
end
