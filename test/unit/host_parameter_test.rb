require 'test_helper'

class HostParameterTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end
  test "should have a reference_id" do
    host_parameter = HostParameter.new
    host_parameter.name = "valid"
    host_parameter.value = "valid"
    assert !host_parameter.save

    host = Host.first
    host_parameter.reference_id = host.id
    assert host_parameter.save
  end

  test "duplicate names cannot exist for a host" do
    @host = hosts(:one)
    as_admin do
      @parameter1 = HostParameter.create :name => "some_parameter", :value => "value", :reference_id => @host.id
      @parameter2 = HostParameter.create :name => "some_parameter", :value => "value", :reference_id => @host.id
    end
    assert !@parameter2.valid?
    assert  @parameter2.errors.full_messages[0] == "Name has already been taken"
  end

  test "duplicate names can exist for different hosts" do
    @host1 = hosts(:one)
    @host2 = hosts(:two)
    as_admin do
      @parameter1 = HostParameter.create! :name => "some_parameter", :value => "value", :reference_id => @host1.id
      @parameter2 = HostParameter.create! :name => "some_parameter", :value => "value", :reference_id => @host2.id
    end
    assert @parameter2.valid?
  end

end
