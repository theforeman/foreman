require 'test_helper'
require 'models/parameters/parameter_validations'

class SubnetParameterTest < ActiveSupport::TestCase
  def self.parameter_class
    :subnet
  end

  include ::ParameterValidations
end
