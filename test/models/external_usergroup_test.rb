require 'test_helper'

class ExternalUsergroupTest < ActiveSupport::TestCase
  test "should not be able to use hidden auth source" do
    eug = FactoryBot.build(:external_usergroup, :auth_source => AuthSourceHidden.first)
    refute_valid eug, :auth_source, /permitted/
  end

  test 'should not allow "Domain Users" as name for AD sources' do
    auth_source = FactoryBot.build_stubbed(:auth_source_ldap, :active_directory)
    eug = FactoryBot.build_stubbed(:external_usergroup,
                           :name => 'Domain Users',
                           :auth_source => auth_source)
    eug.valid?
    assert_match(/special/, eug.errors[:name].first)
  end
end
