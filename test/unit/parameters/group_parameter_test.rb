require 'test_helper'
require 'unit/parameters/parameter_validations'

class GroupParameterTest < ActiveSupport::TestCase
  def self.parameter_class
    :hostgroup
  end

  include ::ParameterValidations
end
