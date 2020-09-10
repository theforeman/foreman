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

  test 'update_usergroups matches LDAP gids with external user groups case insensitively' do
    setup_ldap_stubs

    @auth_source_ldap.expects(:valid_group?).with('IPAUSERS').returns(true)
    external = FactoryBot.create(:external_usergroup, :auth_source => @auth_source_ldap, :name => 'IPAUSERS')
    ldap_user = FactoryBot.create(:user, :login => 'JohnSmith', :mail => 'a@b.com', :auth_source => @auth_source_ldap)
    AuthSourceLdap.any_instance.expects(:users_in_group).with('IPAUSERS').returns(['JohnSmith'])
    external.send(:refresh)
    assert_include ldap_user.usergroups, external.usergroup
  end

  private

  def setup_ldap_stubs
    @auth_source_ldap = FactoryBot.create(:auth_source_ldap)
    User.current = users(:admin)

    # stub out all the LDAP connectivity
    entry = Net::LDAP::Entry.new
    {:givenname => ['test'], :dn => ["uid=test123,cn=users,cn=accounts,dc=example,dc=com"], :mail => ["test123@example.com"], :sn => ["test"]}.each do |k, v|
      entry[k] = v.map { |e| e.encode('UTF-8').force_encoding('ASCII-8BIT') }
    end
    LdapFluff.any_instance.stubs(:valid_user?).returns(true)
    LdapFluff.any_instance.stubs(:find_user).returns([entry])
  end
end
