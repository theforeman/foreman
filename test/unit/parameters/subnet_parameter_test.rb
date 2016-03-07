require 'test_helper'
require 'unit/parameters/parameter_validations'

class SubnetParameterTest < ActiveSupport::TestCase
  def self.parameter_class
    :subnet
  end

  include ::ParameterValidations
end
