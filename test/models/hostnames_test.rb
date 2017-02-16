require 'test_helper'

class HostnameTest < ActiveSupport::TestCase
  context 'hostname validations' do
    setup do
      @hostname = FactoryGirl.build(:hostname)
    end

    test "should be valid" do
      assert_valid @hostname
    end

    test "should save" do
      assert @hostname.save
    end
  end

  test "proxy should respond correctly to has_feature? method" do
    assert hostnames(:puppetmaster).has_feature?('Puppet')
    refute hostnames(:realm).has_feature?('Puppet')
  end
end
