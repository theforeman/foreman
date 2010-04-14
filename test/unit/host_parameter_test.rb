require 'test_helper'

class HostParameterTest < ActiveSupport::TestCase
  test "should have a host_id" do
    host_parameter = HostParameter.new
    host_parameter.name = "valid"
    host_parameter.value = "valid"
    assert !host_parameter.save

    host = Host.first
    host_parameter.host_id = host.id
    assert host_parameter.save
  end
end

