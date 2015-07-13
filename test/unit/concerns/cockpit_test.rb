require 'test_helper'

class DummyCockpit
  include Cockpit
end

class CockpitTest < ActiveSupport::TestCase
  test 'cockpit is enabled if cockpit ping is successful' do
    dummy_cockpit = DummyCockpit.new
    dummy_cockpit.stubs(:operatingsystem).returns(OpenStruct.new(:type => 'Fedora'))
    dummy_cockpit.stubs(:primary_interface).returns(OpenStruct.new(:fqdn => 'http://foo.bar'))
    RestClient.expects(:get).with("#{dummy_cockpit.primary_interface.fqdn}:9090/ping").
      returns('{"service": "cockpit"}')
    assert dummy_cockpit.cockpit_enabled?
  end
end
