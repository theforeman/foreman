# encoding: utf-8
require 'test_helper'

class AuthSourceLdapTest < ActiveSupport::TestCase
  def setup
    @auth_source_ldap = FactoryGirl.create(:auth_source_ldap)
    User.current = users(:admin)
  end

  should validate_presence_of(:name)
  should validate_presence_of(:host)
  should validate_presence_of(:server_type)
  should validate_presence_of(:port)
  should validate_numericality_of(:port).only_integer
  should_not validate_presence_of(:ldap_filter)
  should_not allow_value('(').for(:ldap_filter)
  should allow_value('').for(:ldap_filter)
  should allow_value('    ').for(:ldap_filter)
  should allow_value('key=value').for(:ldap_filter)
  should validate_length_of(:name).is_at_most(60)
  should validate_length_of(:host).is_at_most(60)
  should validate_length_of(:account_password).is_at_most(60)
  should validate_length_of(:account).is_at_most(255)
  should validate_length_of(:base_dn).is_at_most(255)
  should validate_length_of(:ldap_filter).is_at_most(255)
  should validate_length_of(:attr_login).is_at_most(30)
  should validate_length_of(:attr_firstname).is_at_most(30)
  should validate_length_of(:attr_lastname).is_at_most(30)
  should validate_length_of(:attr_mail).is_at_most(30)
  should have_many(:organizations)
  should have_many(:locations)

  test "after initialize if port == 0 should automatically change to 389" do
    other_auth_source_ldap = AuthSourceLdap.new
    assert_equal 389, other_auth_source_ldap.port
  end

  test "should strip the ldap attributes before validate" do
    @auth_source_ldap.attr_login = "following spaces    "
    @auth_source_ldap.attr_firstname = "following spaces    "
    @auth_source_ldap.attr_lastname = "following spaces    "
    @auth_source_ldap.attr_mail = "following spaces    "
    @auth_source_ldap.save

    assert_equal "following spaces", @auth_source_ldap.attr_login
    assert_equal "following spaces", @auth_source_ldap.attr_firstname
    assert_equal "following spaces", @auth_source_ldap.attr_lastname
    assert_equal "following spaces", @auth_source_ldap.attr_mail
  end

  test "return nil if login is blank or password is blank" do
    assert_nil @auth_source_ldap.authenticate("", "")
  end

  test "when auth_method_name is applied should return 'LDAP'" do
    @auth_source_ldap.save

    assert_equal 'LDAP', @auth_source_ldap.auth_method_name
  end

  test "ldap user should be able to login" do
    # stubs out all the actual ldap connectivity, but tests the authenticate
    # method of auth_source_ldap
    setup_ldap_stubs
    LdapFluff.any_instance.stubs(:authenticate?).returns(true)
    LdapFluff.any_instance.stubs(:group_list).returns([])
    assert_not_nil AuthSourceLdap.authenticate("test123", "changeme")
  end

  test "attributes should be encoded and handled in UTF-8" do
    # stubs out all the actual ldap connectivity, but tests the authenticate
    # method of auth_source_ldap
    setup_ldap_stubs('Bär')
    LdapFluff.any_instance.stubs(:authenticate?).returns(true)
    LdapFluff.any_instance.stubs(:group_list).returns([])
    attrs = AuthSourceLdap.authenticate('Bär', 'changeme')
    assert_equal Encoding::UTF_8, attrs[:firstname].encoding
    assert_equal 'Bär', attrs[:firstname]
  end

  test 'update_usergroups returns if entry does not belong to any group' do
    setup_ldap_stubs
    ExternalUsergroup.any_instance.expects(:refresh).never
    LdapFluff.any_instance.expects(:group_list).with('test').returns([])
    @auth_source_ldap.send(:update_usergroups, 'test')
  end

  context 'refresh ldap' do
    setup do
      setup_ldap_stubs
      LdapFluff.any_instance.expects(:group_list).with('test').returns(['ipausers'])
    end

    test 'update_usergroups calls refresh_ldap if entry belongs to some group' do
      @auth_source_ldap.expects(:valid_group?).with('ipausers').returns(true)
      FactoryGirl.create(:external_usergroup, :name => 'ipausers', :auth_source => @auth_source_ldap)
      ExternalUsergroup.any_instance.expects(:refresh)
      @auth_source_ldap.send(:update_usergroups, 'test')
    end

    test 'update_usergroups matches LDAP gids with external user groups case insensitively' do
      @auth_source_ldap.expects(:valid_group?).with('IPAUSERS').returns(true)
      external = FactoryGirl.create(:external_usergroup, :auth_source => @auth_source_ldap, :name => 'IPAUSERS')
      ldap_user = FactoryGirl.create(:user, :login => 'JohnSmith', :mail => 'a@b.com', :auth_source => @auth_source_ldap)
      AuthSourceLdap.any_instance.expects(:users_in_group).with('IPAUSERS').returns(['JohnSmith'])
      @auth_source_ldap.send(:update_usergroups, 'test')
      assert_include ldap_user.usergroups, external.usergroup
    end

    test 'update_usergroups refreshes on all external user groups, in LDAP and in Foreman auth source' do
      @auth_source_ldap.expects(:valid_group?).with('external_usergroup1').returns(true)
      external = FactoryGirl.create(:external_usergroup, :auth_source => @auth_source_ldap)
      User.any_instance.expects(:external_usergroups).returns([external])
      @auth_source_ldap.send(:update_usergroups, 'test')
    end
  end

  test 'update_usergroups is no-op with $login service account' do
    ldap = FactoryGirl.build(:auth_source_ldap, :account => 'DOMAIN/$login')
    User.any_instance.expects(:external_usergroups).never
    ExternalUsergroup.any_instance.expects(:refresh).never
    ldap.send(:update_usergroups, 'test')
  end

  test 'update_usergroups is no-op with usergroup_sync=false' do
    ldap = FactoryGirl.build(:auth_source_ldap, :usergroup_sync => false)
    User.any_instance.expects(:external_usergroups).never
    ExternalUsergroup.any_instance.expects(:refresh).never
    ldap.send(:update_usergroups, 'test')
  end

  test '#to_config with dedicated service account returns hash' do
    conf = FactoryGirl.build(:auth_source_ldap, :service_account).to_config
    assert_kind_of Hash, conf
    refute conf[:anon_queries]
  end

  test '#to_config with $login service account and no username fails' do
    ldap = FactoryGirl.build(:auth_source_ldap, :account => 'DOMAIN/$login')
    assert_raise(Foreman::Exception) { ldap.to_config }
  end

  test '#to_config with $login service account and username returns hash with service user' do
    conf = FactoryGirl.build(:auth_source_ldap, :account => 'DOMAIN/$login').to_config('user', 'pass')
    assert_kind_of Hash, conf
    refute conf[:anon_queries]
    assert_equal 'DOMAIN/user', conf[:service_user]
  end

  test '#to_config with no service account returns hash with anonymous queries' do
    conf = FactoryGirl.build(:auth_source_ldap).to_config('user', 'pass')
    assert_kind_of Hash, conf
    assert conf[:anon_queries]
  end

  test '#to_config keeps encryption nil if tls is not used' do
    AuthSourceLdap.any_instance.stubs(:tls => false)
    conf = FactoryGirl.build(:auth_source_ldap).to_config('user', 'pass')
    assert_nil conf[:encryption]
  end

  test '#to_config enforces verify_mode peer for tls' do
    AuthSourceLdap.any_instance.stubs(:tls => true)
    conf = FactoryGirl.build(:auth_source_ldap).to_config('user', 'pass')
    assert_kind_of Hash, conf[:encryption]
    assert_equal OpenSSL::SSL::VERIFY_PEER, conf[:encryption][:tls_options][:verify_mode]
  end

  test '#ldap_con does not cache connections with user auth' do
    ldap = FactoryGirl.build(:auth_source_ldap, :account => 'DOMAIN/$login')
    refute_equal ldap.ldap_con('user', 'pass'), ldap.ldap_con('user', 'pass')
  end

  test "test connection succeed" do
    setup_ldap_stubs
    LdapFluff.any_instance.stubs(:test).returns(true)
    assert_nothing_raised {@auth_source_ldap.send(:test_connection)}
  end

  test "test connection failed" do
    setup_ldap_stubs
    LdapFluff.any_instance.stubs(:test).raises(StandardError, 'Exception message')
    assert_raise(Foreman::WrappedException) {@auth_source_ldap.send(:test_connection)}
  end

  context 'account_password encryption' do
    setup do
      AuthSourceLdap.any_instance.expects(:encryption_key).at_least_once
        .returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    end

    test "account_password is stored encrypted" do
      auth_source = FactoryGirl.create(:auth_source_ldap, :account_password => 'fakepass')
      assert auth_source.is_decryptable?(auth_source.account_password_in_db)
    end
  end

  context 'save external avatar' do
    let(:temp_dir){Dir.mktmpdir}

    setup do
      AuthSourceLdap.any_instance.stubs(:avatar_path).returns(temp_dir)
    end

    test 'store_avatar can save 8bit ascii files' do
      begin
        auth = AuthSourceLdap.new
        file = File.open("#{temp_dir}/out.txt", 'wb+')
        file_string = File.open(file, 'rb') {|f| f.read} # set the file_string to binary
        file_string += 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVQYV2P4DwABAQEAWk1v8QAAAABJRU5ErkJggg=='
        avatar_hash = Digest::SHA1.hexdigest(file_string)
        assert_equal(Encoding::ASCII_8BIT, file_string.encoding)
        assert_nothing_raised do
          auth.send(:store_avatar, file_string)
        end
        assert(File.exist?("#{temp_dir}/#{avatar_hash}.jpg"))
      ensure
        FileUtils.remove_entry temp_dir
      end
    end
  end

  context 'scoped search' do
    test "should return search results if search free text is auth source name" do
      @auth_source_ldap.name = 'remote'
      @auth_source_ldap.save
      results = AuthSourceLdap.search_for('remote')
      assert_equal(1, results.count)
    end

    test "should return search results for name = auth source name" do
      @auth_source_ldap.name = 'my_ldap'
      @auth_source_ldap.save
      results = AuthSourceLdap.search_for('name = my_ldap')
      assert_equal(1, results.count)
      assert_equal 'my_ldap', results.first.name
    end
  end

  private

  def setup_ldap_stubs(givenname = 'test')
    # stub out all the LDAP connectivity
    entry = Net::LDAP::Entry.new
    {:givenname=>[givenname], :dn=>["uid=test123,cn=users,cn=accounts,dc=example,dc=com"], :mail=>["test123@example.com"], :sn=>["test"]}.each do |k, v|
      entry[k] = v.map { |e| e.encode('UTF-8').force_encoding('ASCII-8BIT') }
    end
    LdapFluff.any_instance.stubs(:valid_user?).returns(true)
    LdapFluff.any_instance.stubs(:find_user).returns([entry])
  end
end
