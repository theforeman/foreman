require 'test_helper'

class HostParameterTest < ActiveSupport::TestCase
  test "should have a host_id" do
    host_parameter = HostParameter.new
    host_parameter.name = "valid"
    host_parameter.value = "valid"
    assert !host_parameter.save

    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
                        :domain => Domain.find_or_create_by_name("company.com"),
                        :operatingsystem => Operatingsystem.create(:name => "linux", :major => 389),
                        :architecture => Architecture.find_or_create_by_name("i386"),
                        :environment => Environment.find_or_create_by_name("envy"),
                        :disk => "empty partition"

    host_parameter.host_id = host.id
    assert host_parameter.save
  end
end

