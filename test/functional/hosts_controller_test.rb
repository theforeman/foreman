require 'test_helper'

class HostsControllerTest < ActionController::TestCase
  setup :initialize_host

  def test_show
    get :show, {:id => Host.first.name}, set_session_user
    assert_template 'show'
  end

  def test_create_invalid
    Host.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Host.any_instance.stubs(:valid?).returns(true)
    post :create, {:host => {:name => "test"}}, set_session_user
    assert_redirected_to host_url(assigns('host'))
  end

  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should render 404 when host is not found" do
    get :show, {:id => "no.such.host"}, set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
    assert_template 'new'
  end

  test "should create new host" do
    assert_difference 'Host.count' do
      post :create, { :commit => "Create",
        :host => {:name => "myotherfullhost",
          :mac => "aabbecddee06",
          :ip => "2.3.4.125",
          :domain_id => domains(:mydomain).id,
          :operatingsystem_id => operatingsystems(:redhat).id,
          :architecture_id => architectures(:x86_64).id,
          :environment_id => environments(:production).id,
          :subnet_id => subnets(:one).id,
          :medium_id => media(:one).id,
          :realm_id => realms(:myrealm).id,
          :disk => "empty partition",
          :puppet_proxy_id => smart_proxies(:puppetmaster).id,
          :root_pass           => "xybxa6JUkz63w",
          :location_id => taxonomies(:location1).id,
          :organization_id => taxonomies(:organization1).id
        }
      }, set_session_user
    end
    assert_redirected_to host_url(assigns['host'])
  end

  test "should get edit" do
    get :edit, {:id => @host.name}, set_session_user
    assert_response :success
    assert_template 'edit'
  end

  test "should update host" do
    put :update, { :commit => "Update", :id => @host.name, :host => {:disk => "ntfs"} }, set_session_user
    @host = Host.find(@host)
    assert_equal @host.disk, "ntfs"
  end

  def test_update_invalid
    Host.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Host.first.name, :host => {}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Host.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Host.first.name, :host => {}}, set_session_user
    assert_redirected_to host_url(assigns(:host))
  end

  test "should destroy host" do
    assert_difference('Host.count', -1) do
      delete :destroy, {:id => @host.name}, set_session_user
    end
    assert_redirected_to hosts_url
  end

  test "externalNodes should render correctly when format text/html is given" do
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @host.name}, set_session_user
    assert_response :success
    assert_template :text => @host.info.to_yaml.gsub("\n","<br/>")
  end

  test "externalNodes should render yml request correctly" do
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @host.name, :format => "yml"}, set_session_user
    assert_response :success
    assert_template :text => @host.info.to_yaml
  end

  test "when host is not saved after setBuild, the flash should inform it" do
    Host.any_instance.stubs(:setBuild).returns(false)
    @request.env['HTTP_REFERER'] = hosts_path

    put :setBuild, {:id => @host.name}, set_session_user
    assert_response :found
    assert_redirected_to hosts_path
    assert_not_nil flash[:error]
    assert flash[:error] =~ /Failed to enable #{@host} for installation/
  end

  context "when host is saved after setBuild" do
    setup do
      @request.env['HTTP_REFERER'] = hosts_path
    end

    teardown do
     Host::Managed.any_instance.unstub(:setBuild)
      @request.env['HTTP_REFERER'] = ''
    end

    test "the flash should inform it" do
      Host::Managed.any_instance.stubs(:setBuild).returns(true)
      put :setBuild, {:id => @host.name}, set_session_user
      assert_response :found
      assert_redirected_to hosts_path
      assert_not_nil flash[:notice]
      assert flash[:notice] == "Enabled #{@host} for rebuild on next boot"
    end

    test 'and reboot was requested, the flash should inform it' do
      Host::Managed.any_instance.stubs(:setBuild).returns(true)
      # Setup a power mockup
      class PowerShmocker
        def reset
          true
        end
      end
      Host::Managed.any_instance.stubs(:power).returns(PowerShmocker.new())

      put :setBuild, {:id => @host.name, :host => {:build => '1'}}, set_session_user
      assert_response :found
      assert_redirected_to hosts_path
      assert_not_nil flash[:notice]
      assert_equal(flash[:notice], "Enabled #{@host} for reboot and rebuild")
    end

    test 'and reboot requested and reboot failed, the flash should inform it' do
      Host::Managed.any_instance.stubs(:setBuild).returns(true)
      put :setBuild, {:id => @host.name, :host => {:build => '1'}}, set_session_user
      assert_raise Foreman::Exception do
        @host.power.reset
      end
      assert_response :found
      assert_redirected_to hosts_path
      assert_not_nil flash[:notice]
      assert_equal(flash[:notice], "Enabled #{@host} for rebuild on next boot")
    end
  end

  def test_clone
    ComputeResource.any_instance.stubs(:vm_compute_attributes_for).returns({})
    get :clone, {:id => Host.first.name}, set_session_user
    assert assigns(:clone_host)
    assert_template 'new'
  end

  def test_clone_empties_fields
    ComputeResource.any_instance.stubs(:vm_compute_attributes_for).returns({})
    get :clone, {:id => Host.first.name}, set_session_user
    refute assigns(:host).name
    refute assigns(:host).ip
    refute assigns(:host).mac
  end

  def setup_user(operation, type = 'hosts', filter = nil)
    super
  end

  def setup_user_and_host(operation, filter = nil, &block)
    setup_user operation, 'hosts', filter, &block

    as_admin do
      @host1           = FactoryGirl.create(:host)
      @host1.owner     = users(:admin)
      @host1.save!
      @host2           = FactoryGirl.create(:host)
      @host2.owner     = users(:admin)
      @host2.save!
    end
    Host.per_page = 1000
    @request.session[:user] = @one.id
  end

  test 'user with view host rights and domain is set should succeed in viewing host1 but fail for host2' do
    setup_user_and_host "view", "domain_id = #{domains(:mydomain).id}"

    as_admin do
      @host1.update_attribute(:domain, domains(:mydomain))
      @host2.update_attribute(:domain, domains(:yourdomain))
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert_match /#{@host1.shortname}/, @response.body
    refute_match /#{@host2.name}/, @response.body
  end

  test 'user with view host rights and ownership is set should succeed in viewing host1 but fail for host2' do
    setup_user_and_host "view", "owner_id = #{users(:one).id} and owner_type = User"
    as_admin do
      @host1.owner = @one
      @host2.owner = users(:two)
      @host1.save!
      @host2.save!
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert_match /#{@host1.name}/, @response.body
    refute_match /#{@host2.name}/, @response.body
  end

  test 'user with view host rights and hostgroup is set should succeed in viewing host1 but fail for host2' do
    setup_user_and_host "view", "hostgroup_id = #{hostgroups(:common).id}"
    as_admin do
      @host1.hostgroup = hostgroups(:common)
      @host2.hostgroup = hostgroups(:unusual)
      @host1.save!
      @host2.save!
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert_match /#{@host1.name}/, @response.body
    refute_match /#{@host2.name}/, @response.body
  end

  test 'user with edit host rights and facts are set should succeed in viewing host1 but fail for host2' do
    setup_user_and_host "view", "facts.architecture = \"x86_64\""
    as_admin do
      fn_id = FactName.find_or_create_by_name("architecture").id
      FactValue.create! :host => @host1, :fact_name_id => fn_id, :value    => "x86_64"
      FactValue.create! :host => @host2, :fact_name_id => fn_id, :value    => "i386"
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert_match /#{@host1.name}/, @response.body
    refute_match /#{@host2.name}/, @response.body
  end

  test 'user with view host rights should fail to edit host' do
    setup_user_and_host "view"
    get :edit, {:id => @host1.id}, set_session_user.merge(:user => @one.id)
    assert_equal @response.status, 403
  end

  test 'multiple without hosts' do
    post :update_multiple_hostgroup, {}, set_session_user
    assert_redirected_to hosts_url
    assert_equal "No hosts selected", flash[:error]

    # now try to pass an invalid id
    post :update_multiple_hostgroup, {:host_ids => [-1], :host_names => ["no.such.host"]}, set_session_user

    assert_redirected_to hosts_url
    assert_equal "No hosts were found with that id or name", flash[:error]
  end

  test 'multiple hostgroup change by host ids' do
    @request.env['HTTP_REFERER'] = hosts_path
    # check that we have hosts and their hostgroup is empty
    hosts = FactoryGirl.create_list(:host, 2)
    hosts.each { |host| assert_nil host.hostgroup }

    hostgroup = hostgroups(:unusual)
    post :update_multiple_hostgroup, { :host_ids => hosts.map(&:id), :hostgroup => { :id => hostgroup.id } }, set_session_user
    assert_response :redirect

    # reloads hosts
    hosts.map! {|h| Host.find(h.id)}
    hosts.each { |host| assert_equal hostgroup, host.hostgroup }
  end


  test 'multiple hostgroup change by host names' do
    @request.env['HTTP_REFERER'] = hosts_path
    hosts = FactoryGirl.create_list(:host, 2)
    host_names = hosts.map(&:name)
    # check that we have hosts and their hostgroup is empty
    host_names.each do |name|
      host = Host.find_by_name name
      assert_not_nil host
      assert_nil host.hostgroup
    end

    hostgroup = hostgroups(:common)
    post :update_multiple_hostgroup, { :host_names => host_names, :hostgroup  => { :id => hostgroup.id} }, set_session_user
    assert_response :redirect

    host_names.each do |name|
      host = Host.find_by_name name
      assert_not_nil host
      assert_equal host.hostgroup, hostgroup
    end
  end


  def setup_multiple_environments
    setup_user_and_host "edit"
    as_admin do
      @host1, @host2 = FactoryGirl.create_list(:host, 2, :environment => environments(:production))
    end
  end

  test "user with edit host rights with update environments should change environments" do
    @request.env['HTTP_REFERER'] = hosts_path
    setup_multiple_environments
    assert @host1.environment == environments(:production)
    assert @host2.environment == environments(:production)
    post :update_multiple_environment, { :host_ids => [@host1.id, @host2.id],
      :environment => { :id => environments(:global_puppetmaster).id}},
      set_session_user.merge(:user => users(:admin).id)
    assert Host.find(@host1.id).environment == environments(:global_puppetmaster)
    assert Host.find(@host2.id).environment == environments(:global_puppetmaster)
  end

  test "should inherit the hostgroup environment if *inherit from hostgroup* selected" do
    @request.env['HTTP_REFERER'] = hosts_path
    setup_multiple_environments
    assert @host1.environment == environments(:production)
    assert @host2.environment == environments(:production)

    hostgroup = hostgroups(:common)
    hostgroup.environment = environments(:global_puppetmaster)
    hostgroup.save(:validate => false)

    @host1.hostgroup = hostgroup
    @host1.save(:validate => false)
    @host2.hostgroup = hostgroup
    @host2.save(:validate => false)

    params = { :host_ids => [@host1.id, @host2.id],
      :environment => { :id => 'inherit' } }

    post :update_multiple_environment, params,
      set_session_user.merge(:user => users(:admin).id)

    assert Host.find(@host1.id).environment == hostgroup.environment
    assert Host.find(@host2.id).environment == hostgroup.environment
  end

  test "user with edit host rights with update parameters should change parameters" do
    setup_multiple_environments
    @host1.host_parameters = [HostParameter.create(:name => "p1", :value => "yo")]
    @host2.host_parameters = [HostParameter.create(:name => "p1", :value => "hi")]
    post :update_multiple_parameters,
      {:name => { "p1" => "hello"},:host_ids => [@host1.id, @host2.id]},
      set_session_user.merge(:user => users(:admin).id)
    assert Host.find(@host1.id).host_parameters[0][:value] == "hello"
    assert Host.find(@host2.id).host_parameters[0][:value] == "hello"
  end
  test "should get errors" do
    get :errors, {}, set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should get active" do
    get :active, {}, set_session_user
    assert_response :success
    assert_template :partial => "_list"
    assert_template 'index'
  end

  test "should get out of sync" do
    get :out_of_sync, {}, set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should get pending" do
    get :pending, {}, set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should get disabled hosts" do
    get :disabled, {}, set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should get disabled hosts for a user with a fact_filter" do
    one = users(:one)
    one.roles << [roles(:manager)]
    fn  = FactName.create :name =>"architecture"
    get :disabled, {:user => one.id}, set_session_user
    assert_response :success
  end

  test "if only authorize_login_delegation is set, REMOTE_USER should be
        ignored for API requests" do
    Setting[:authorize_login_delegation] = true
    Setting[:authorize_login_delegation_api] = false
    set_remote_user_to users(:admin)
    User.current = nil # User.current is admin at this point (from initialize_host)
    host = Host.first
    get :show, {:id => host.to_param, :format => 'json'}
    assert_response 401
    get :show, {:id => host.to_param}
    assert_response :success
  end

  test "if both authorize_login_delegation{,_api} are unset,
        REMOTE_USER should ignored in all cases" do
    Setting[:authorize_login_delegation] = false
    Setting[:authorize_login_delegation_api] = false
    set_remote_user_to users(:admin)
    User.current = nil # User.current is admin at this point (from initialize_host)
    host = Host.first
    get :show, {:id => host.to_param, :format => 'json'}
    assert_response 401
    get :show, {:id => host.to_param}
    assert_redirected_to "/users/login"
  end

  def set_remote_user_to(user)
    @request.env['REMOTE_USER'] = user.login
  end

  def test_submit_multiple_build
    host1, host2 = FactoryGirl.create_list(:host, 2, :managed)
    assert !host1.build
    assert !host2.build
    post :submit_multiple_build, {:host_ids => [host1.id, host2.id]}, set_session_user
    assert_response :found
    assert_redirected_to hosts_path
    assert flash[:notice] == "The selected hosts will execute a build operation on next reboot"
    assert Host.find(host1).build
    assert Host.find(host2).build
  end

  def test_set_manage
    @request.env['HTTP_REFERER'] = edit_host_path @host
    assert @host.update_attribute :managed, false
    assert_empty @host.errors
    put :toggle_manage, {:id => @host.name}, set_session_user
    assert_redirected_to :controller => :hosts, :action => :edit
    assert flash[:notice] == "Foreman now manages the build cycle for #{@host.name}"
  end

  def test_unset_manage
    @request.env['HTTP_REFERER'] = edit_host_path @host
    assert @host.update_attribute :managed, true
    assert_empty @host.errors
    put :toggle_manage, {:id => @host.name}, set_session_user
    assert_redirected_to :controller => :hosts, :action => :edit
    assert flash[:notice] == "Foreman now no longer manages the build cycle for #{@host.name}"
  end

  test 'when ":restrict_registered_puppetmasters" is false, HTTP requests should be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = false
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @host.name, :format => "yml"}
    assert_response :success
  end

  test 'hosts with a registered smart proxy on should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @host.name, :format => "yml"}
    assert_response :success
  end

  test 'hosts without a registered smart proxy on should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['another.host'])
    get :externalNodes, {:name => @host.name, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'hosts with a registered smart proxy and SSL cert should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @host.name, :format => "yml"}
    assert_response :success
  end

  test 'hosts in trusted hosts list and SSL cert should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    Setting[:trusted_puppetmaster_hosts] = ['else.where']

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @host.name, :format => "yml"}
    assert_response :success
  end

  test 'hosts with comma-separated SSL DN should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    Setting[:trusted_puppetmaster_hosts] = ['foreman.example']

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=foreman.example,OU=PUPPET,O=FOREMAN,ST=North Carolina,C=US'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @host.name, :format => "yml"}
    assert_response :success
  end

  test 'hosts with slash-separated SSL DN should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    Setting[:trusted_puppetmaster_hosts] = ['foreman.linux.lab.local']

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = '/C=US/ST=NC/L=City/O=Example/OU=IT/CN=foreman.linux.lab.local/emailAddress=user@example.com'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @host.name, :format => "yml"}
    assert_response :success
  end

  test 'hosts without a registered smart proxy but with an SSL cert should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=another.host'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    get :externalNodes, {:name => @host.name, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'hosts with an unverified SSL cert should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'FAILURE'
    get :externalNodes, {:name => @host.name, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'when "require_ssl_puppetmasters" and "require_ssl" are true, HTTP requests should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = true

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @host.name, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'when "require_ssl_puppetmasters" is true and "require_ssl" is false, HTTP requests should be able to get externalNodes' do
    User.current = nil
    # since require_ssl_puppetmasters is only applicable to HTTPS connections, both should be set
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @host.name, :format => "yml"}
    assert_response :success
  end

  test 'authenticated users over HTTP should be able to get externalNodes' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['users.host'])
    get :externalNodes, {:name => @host.name, :format => "yml"}, set_session_user
    assert_response :success
  end

  test 'authenticated users over HTTPS should be able to get externalNodes' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['users.host'])
    @request.env['HTTPS'] = 'on'
    get :externalNodes, {:name => @host.name, :format => "yml"}, set_session_user
    assert_response :success
  end

  #Pessimistic - Location
  test "update multiple location fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    location = taxonomies(:location1)
    post :update_multiple_location, {
      :location => {:id => location.id, :optimistic_import => "no"},
      :host_ids => Host.all.map(&:id)
    }, set_session_user
    assert_redirected_to :controller => :hosts, :action => :index
    assert flash[:error] == "Cannot update Location to Location 1 because of mismatch in settings"
  end
  test "update multiple location does not update location of hosts if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    location = taxonomies(:location1)
    assert_difference "location.hosts.count", 0 do
      post :update_multiple_location, {
        :location => {:id => location.id, :optimistic_import => "no"},
        :host_ids => Host.all.map(&:id)
      }, set_session_user
    end
  end
  test "update multiple location does not import taxable_taxonomies rows if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    location = taxonomies(:location1)
    assert_difference "location.taxable_taxonomies.count", 0 do
      post :update_multiple_location, {
        :location => {:id => location.id, :optimistic_import => "no"},
        :host_ids => Host.all.map(&:id)
      }, set_session_user
    end
  end

  #Optimistic - Location
  test "update multiple location succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    location = taxonomies(:location1)
    post :update_multiple_location, {
      :location => {:id => location.id, :optimistic_import => "yes"},
      :host_ids => Host.all.map(&:id)
    }, set_session_user
    assert_redirected_to :controller => :hosts, :action => :index
    assert_equal "Updated hosts: Changed Location", flash[:notice]
  end
  test "update multiple location updates location of hosts if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    location = taxonomies(:location1)
    cnt_hosts_location = location.hosts.count
    assert_difference "location.hosts.count", (Host.count - cnt_hosts_location) do
      post :update_multiple_location, {
        :location => {:id => location.id, :optimistic_import => "yes"},
        :host_ids => Host.all.map(&:id)
      }, set_session_user
    end
  end
  test "update multiple location imports taxable_taxonomies rows if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    location = taxonomies(:location1)
    domain = FactoryGirl.create(:domain, :locations => [taxonomies(:location2)])
    hosts = FactoryGirl.create_list(:host, 2, :domain => domain,
                                    :environment => environments(:production),
                                    :location => taxonomies(:location2))
    assert_difference "location.taxable_taxonomies.count", 1 do
      post :update_multiple_location, {
        :location => {:id => location.id, :optimistic_import => "yes"},
        :host_ids => hosts.map(&:id)
      }, set_session_user
    end
  end

  #Pessimistic - organization
  test "update multiple organization fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    post :update_multiple_organization, {
      :organization => {:id => organization.id, :optimistic_import => "no"},
      :host_ids => Host.all.map(&:id)
    }, set_session_user
    assert_redirected_to :controller => :hosts, :action => :index
    assert_equal "Cannot update Organization to Organization 1 because of mismatch in settings", flash[:error]
  end
  test "update multiple organization does not update organization of hosts if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    assert_difference "organization.hosts.count", 0 do
      post :update_multiple_organization, {
        :organization => {:id => organization.id, :optimistic_import => "no"},
        :host_ids => Host.all.map(&:id)
      }, set_session_user
    end
  end
  test "update multiple organization does not import taxable_taxonomies rows if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    assert_difference "organization.taxable_taxonomies.count", 0 do
      post :update_multiple_organization, {
        :organization => {:id => organization.id, :optimistic_import => "no"},
        :host_ids => Host.all.map(&:id)
      }, set_session_user
    end
  end

  #Optimistic - Organization
  test "update multiple organization succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    post :update_multiple_organization, {
      :organization => {:id => organization.id, :optimistic_import => "yes"},
      :host_ids => Host.all.map(&:id)
    }, set_session_user
    assert_redirected_to :controller => :hosts, :action => :index
    assert_equal "Updated hosts: Changed Organization", flash[:notice]
  end
  test "update multiple organization updates organization of hosts if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    cnt_hosts_organization = organization.hosts.count
    assert_difference "organization.hosts.count", (Host.count - cnt_hosts_organization) do
      post :update_multiple_organization, {
        :organization => {:id => organization.id, :optimistic_import => "yes"},
        :host_ids => Host.all.map(&:id)
      }, set_session_user
    end
  end
  test "update multiple organization imports taxable_taxonomies rows if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    domain = FactoryGirl.create(:domain, :organizations => [taxonomies(:organization2)])
    hosts = FactoryGirl.create_list(:host, 2, :domain => domain,
                                    :environment => environments(:production),
                                    :organization => taxonomies(:organization2))
    assert_difference "organization.taxable_taxonomies.count", 1 do
      post :update_multiple_organization, {
        :organization => { :id => organization.id, :optimistic_import => "yes"},
        :host_ids => hosts.map(&:id)
      }, set_session_user
    end
  end

  test "can change sti type to valid subtype" do
    class Host::Valid < Host::Base; end
    put :update, { :commit => "Update", :id => @host.name, :host => {:type => "Host::Valid"} }, set_session_user
    @host = Host::Base.find(@host.id)
    assert_equal "Host::Valid", @host.type
  end

  test "cannot change sti type to invalid subtype" do
    old_type = @host.type
    put :update, { :commit => "Update", :id => @host.name, :host => {:type => "Host::Notvalid"} }, set_session_user
    @host = Host.find(@host.id)
    assert_equal old_type, @host.type
  end

  test "blank root password submitted does not erase existing password" do
    old_root_pass = @host.root_pass
    put :update, { :commit => "Update", :id => @host.name, :host => {:root_pass => ''} }, set_session_user
    @host = Host.find(@host.id)
    assert_equal old_root_pass, @host.root_pass
  end

  test "blank BMC password submitted does not erase existing password" do
    bmc1 = @host.interfaces.build(:name => "bmc1", :mac => '52:54:00:b0:0c:fc', :type => 'Nic::BMC',
                      :ip => '10.0.1.101', :username => 'user1111', :password => 'abc123456', :provider => 'IPMI')
    assert bmc1.save
    old_password = bmc1.password
    put :update, { :commit => "Update", :id => @host.name, :host => {:interfaces_attributes => {"0" => {:id => bmc1.id, :password => ''} } } }, set_session_user
    @host = Host.find(@host.id)
    assert_equal old_password, @host.interfaces.bmc.first.password
  end

  # To test that work-around for Rails bug - https://github.com/rails/rails/issues/11031
  test "BMC password updates successful even if attrs serialized field is the only dirty field" do
    bmc1 = @host.interfaces.build(:name => "bmc1", :mac => '52:54:00:b0:0c:fc', :type => 'Nic::BMC',
                      :ip => '10.0.1.101', :username => 'user1111', :password => 'abc123456', :provider => 'IPMI')
    assert bmc1.save
    new_password = "topsecret"
    put :update, { :commit => "Update", :id => @host.name, :host => {:interfaces_attributes => {"0" => {:id => bmc1.id, :password => new_password, :mac => bmc1.mac} } } }, set_session_user
    @host = Host.find(@host.id)
    assert_equal new_password, @host.interfaces.bmc.first.password
  end

  test "#disassociate shows error when used on non-CR host" do
    host = FactoryGirl.create(:host)
    @request.env["HTTP_REFERER"] = hosts_path
    put :disassociate, {:id => host.to_param}, set_session_user
    assert_response :redirect, hosts_path
    assert_not_nil flash[:error]
  end

  test "#disassociate removes UUID and CR association from host" do
    host = FactoryGirl.create(:host, :on_compute_resource)
    @request.env["HTTP_REFERER"] = hosts_path
    put :disassociate, {:id => host.to_param}, set_session_user
    assert_response :redirect, hosts_path
    host.reload
    refute host.uuid
    refute host.compute_resource_id
  end

  test '#update_multiple_disassociate' do
    host = FactoryGirl.create(:host, :on_compute_resource)
    post :update_multiple_disassociate, {:host_ids => [host.id], :host_names => [host.name]}, set_session_user
    assert_response :redirect, hosts_path
    assert_not_nil flash[:notice]
    host.reload
    refute host.uuid
    refute host.compute_resource_id
  end

  test '#review_before_build' do
    HostBuildStatus.any_instance.stubs(:host_status).returns(true)
    xhr :get, :review_before_build, {:id => @host.name}, set_session_user
    assert_response :success
    assert_template 'review_before_build'
  end

  test 'template_used returns templates' do
    @host.setBuild
    nic=FactoryGirl.create(:nic_managed, :host => @host)
    attrs = @host.attributes
    attrs[:interfaces_attributes] = nic.attributes
    xhr :put, :template_used, {:provisioning => 'build', :host => attrs }, set_session_user
    assert_response :success
    assert_template :partial => '_provisioning'
  end

  test 'process_taxonomy renders a host from the params correctly' do
    nic=FactoryGirl.create(:nic_managed, :host => @host)
    attrs = @host.attributes
    attrs[:interfaces_attributes] = nic.attributes
    xhr :put, :process_taxonomy, { :host => attrs }, set_session_user
    assert_response :success
    assert_template :partial => '_form'
  end

  private
  def initialize_host
    User.current = users(:admin)
    disable_orchestration
    @host = Host.create(:name               => "myfullhost",
                        :mac                => "aabbecddeeff",
                        :ip                 => "2.3.4.99",
                        :domain_id          => domains(:mydomain).id,
                        :operatingsystem_id => operatingsystems(:redhat).id,
                        :architecture_id    => architectures(:x86_64).id,
                        :environment_id     => environments(:production).id,
                        :subnet_id          => subnets(:one).id,
                        :disk               => "empty partition",
                        :puppet_proxy_id    => smart_proxies(:puppetmaster).id,
                        :root_pass          => "123456789",
                        :location_id        => taxonomies(:location1).id,
                        :organization_id    => taxonomies(:organization1).id
                       )
  end
end
