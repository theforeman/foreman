require 'test_helper'
require 'unit/parameters/parameter_validations'

class OrganizationParameterTest < ActiveSupport::TestCase
  def self.parameter_class
    :organization
  end

  include ::ParameterValidations
end
