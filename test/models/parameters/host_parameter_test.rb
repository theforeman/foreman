require 'test_helper'
require 'models/parameters/parameter_validations'

class HostParameterTest < ActiveSupport::TestCase
  def self.parameter_class
    :host
  end

  include ::ParameterValidations
end
