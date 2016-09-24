require 'test_helper'
require 'models/parameters/parameter_validations'

class DomainParameterTest < ActiveSupport::TestCase
  def self.parameter_class
    :domain
  end

  include ::ParameterValidations
end
