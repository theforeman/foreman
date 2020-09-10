require 'test_helper'
require 'models/parameters/parameter_validations'

class LocationParameterTest < ActiveSupport::TestCase
  def self.parameter_class
    :location
  end

  include ::ParameterValidations
end
