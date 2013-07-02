require 'test_helper'

class HostsControllerTest < ActionController::TestCase
  setup :initialize_host

  def test_show
    get :show, {:id => Host.first.name}, set_session_user
    assert_template 'show'
  end

  def test_show_json
    host = Host.first
    get :show, {:id => host.to_param, :format => 'json'}, set_session_user
    json = ActiveSupport::JSON.decode(@response.body)
    assert_equal host.name, json["host"]["name"]
  end

  def test_show_json_should_have_nested_host_params
    host = Host.first
    get :show, {:id => host.to_param, :format => 'json'}, set_session_user
    json = ActiveSupport::JSON.decode(@response.body)
    assert json["host"]["host_parameters"].is_a?(Array)
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

  test "should get index via json" do
    get :index, {:format => "json"}, set_session_user
    assert_response :success
    hosts = ActiveSupport::JSON.decode(@response.body)
    assert !hosts.empty?
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
          :disk => "empty partition",
          :puppet_proxy_id => smart_proxies(:puppetmaster).id
        }
      }, set_session_user
    end
    assert_redirected_to host_url(assigns['host'])
  end

  test "should create new host via json" do
    assert_difference 'Host.count' do
      post :create, { :format => "json", :commit => "Create",
        :host => {:name => "myotherfullhost",
          :mac => "e4:1f:22:cc:36:55",
          :ip => "2.3.4.125",
          :domain_id => domains(:mydomain).id,
          :operatingsystem_id => operatingsystems(:redhat).id,
          :architecture_id => architectures(:x86_64).id,
          :environment_id => environments(:production).id,
          :subnet_id => subnets(:one).id,
          :disk => "empty partition",
          :puppet_proxy_id => smart_proxies(:puppetmaster).id
        }
      }, set_session_user
    end
    host = ActiveSupport::JSON.decode(@response.body)
    assert_response :created

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

  def test_update_valid_json
    Host.any_instance.stubs(:valid?).returns(true)
    put :update, {:format => "json", :id => Host.first.name, :host => {}}, set_session_user
    host = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
  end

  test "should destroy host" do
    assert_difference('Host.count', -1) do
      delete :destroy, {:id => @host.name}, set_session_user
    end
    assert_redirected_to hosts_url
  end

  test "should destroy host via json" do
    assert_difference('Host.count', -1) do
      delete :destroy, {:format => "json", :id => @host.name}, set_session_user
    end
    host = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
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

  test "when host is saved after setBuild, the flash should inform it" do
    Host.any_instance.stubs(:setBuild).returns(true)
    @request.env['HTTP_REFERER'] = hosts_path

    get :setBuild, {:id => @host.name}, set_session_user
    assert_response :found
    assert_redirected_to hosts_path
    assert_not_nil flash[:notice]
    assert flash[:notice] == "Enabled #{@host} for rebuild on next boot"
  end

  test "when host is not saved after setBuild, the flash should inform it" do
    Host.any_instance.stubs(:setBuild).returns(false)
    @request.env['HTTP_REFERER'] = hosts_path

    get :setBuild, {:id => @host.name}, set_session_user
    assert_response :found
    assert_redirected_to hosts_path
    assert_not_nil flash[:error]
    assert flash[:error] =~ /Failed to enable #{@host} for installation/
  end

  def test_clone
    get :clone, {:id => Host.first.name}, set_session_user
    assert_template 'new'
  end

  def setup_user_and_host operation
    as_admin do
      @one             = users(:one)
      @one.domains     = []
      @one.hostgroups  = []
      @one.user_facts  = []
      @host1           = hosts(:one)
      @host1.owner     = users(:admin)
      @host1.save!
      @host2           = hosts(:two)
      @host2.owner     = users(:admin)
      @host2.save!
      @one.roles       = [Role.find_by_name('Anonymous'), Role.find_by_name("#{operation.capitalize} hosts")]
    end
    Host.per_page == 1000
    @request.session[:user] = @one.id
  end

  test 'user with edit host rights and domain is set should succeed in viewing host1' do
    setup_user_and_host "Edit"
    as_admin do
      @one.domains  = [domains(:mydomain)]
      @host1.update_attribute(:domain, domains(:mydomain))
      @host2.update_attribute(:domain, domains(:yourdomain))
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert_match /#{@host1.shortname}/, @response.body
  end

  test 'user with edit host rights and domain is set should fail to view host2' do
    setup_user_and_host "Edit"
    as_admin do
      @one.domains  = [domains(:mydomain)]
      @host1.domain = domains(:mydomain)
      @host2.domain = domains(:yourdomain)
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body !~ /#{@host2.name}/
  end

  test 'user with edit host rights and ownership is set should succeed in viewing host1' do
    setup_user_and_host "Edit"
    as_admin do
      @host1.owner = @one
      @host2.owner = users(:two)
      @one.filter_on_owner = true
      @one.save!
      @host1.save!
      @host2.save!
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body =~ /#{@host1.name}/
  end

  test 'user with edit host rights and ownership is set should fail to view host2' do
    setup_user_and_host "Edit"
    as_admin do
      @host1.owner = @one
      @host2.owner = users(:two)
      @one.filter_on_owner = true
      @one.save!
      @host1.save!
      @host2.save!
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body !~ /#{@host2.name}/
  end

  test 'user with edit host rights and hostgroup is set should succeed in viewing host1' do
    setup_user_and_host "Edit"
    as_admin do
      @host1.hostgroup = hostgroups(:common)
      @host2.hostgroup = hostgroups(:unusual)
      @one.hostgroups  = [hostgroups(:common)]
      @host1.save!
      @host2.save!
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body =~ /#{@host1.name}/
  end

  test 'user with edit host rights and hostgroup is set should fail to view host2' do
    setup_user_and_host "Edit"
    as_admin do
      @host1.hostgroup = hostgroups(:common)
      @host2.hostgroup = hostgroups(:unusual)
      @one.hostgroups  = [hostgroups(:common)]
      @host1.save!
      @host2.save!
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body !~ /#{@host2.name}/
  end

  test 'user with edit host rights and facts are set should succeed in viewing host1' do
    setup_user_and_host "Edit"
    as_admin do
      fn_id = FactName.find_or_create_by_name("architecture").id
      FactValue.create! :host => @host1, :fact_name_id => fn_id, :value    => "x86_64"
      FactValue.create! :host => @host2, :fact_name_id => fn_id, :value    => "i386"
      UserFact.create!  :user => @one,   :fact_name_id => fn_id, :criteria => "x86_64", :operator => "=", :andor => "or"
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body =~ /#{@host1.name}/
  end

  test 'user with edit host rights and facts are set should fail to view host2' do
    setup_user_and_host "Edit"
    as_admin do
      fn_id = FactName.find_or_create_by_name("architecture").id
      FactValue.create! :host => @host1, :fact_name_id => fn_id, :value    => "x86_64"
      FactValue.create! :host => @host2, :fact_name_id => fn_id, :value    => "i386"
      UserFact.create!  :user => @one,   :fact_name_id => fn_id, :criteria => "x86_64", :operator => "=", :andor => "or"
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body !~ /#{@host2.name}/
  end

  test 'user with view host rights should fail to edit host' do
    setup_user_and_host "View"
    get :edit, {:id => @host1.id}, set_session_user.merge(:user => @one.id)
    assert_equal @response.status, 403
  end

  test 'user with view host rights should should succeed in viewing hosts' do
    setup_user_and_host "View"
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
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
    hosts = [hosts(:one), hosts(:two)]
    hosts.each { |host| assert_nil host.hostgroup }

    hostgroup = hostgroups(:unusual)
    post :update_multiple_hostgroup, { :host_ids => hosts.map(&:id), :hostgroup => { :id => hostgroup.id } }, set_session_user

    # reloads hosts
    hosts.map! {|h| Host.find(h.id)}
    hosts.each { |host| assert_equal hostgroup, host.hostgroup }
  end


  test 'multiple hostgroup change by host names' do
    @request.env['HTTP_REFERER'] = hosts_path
    host_names = %w{temp.yourdomain.net my5name.mydomain.net }
    # check that we have hosts and their hostgroup is empty
    host_names.each do |name|
      host = Host.find_by_name name
      assert_not_nil host
      assert_nil host.hostgroup
    end

    hostgroup = hostgroups(:common)
    post :update_multiple_hostgroup, { :host_names => host_names, :hostgroup  => { :id => hostgroup.id} }, set_session_user

    host_names.each do |name|
      host = Host.find_by_name name
      assert_not_nil host
      assert_equal host.hostgroup, hostgroup
    end
  end


  def setup_multiple_environments
    setup_user_and_host "edit"
    as_admin do
      @host1 = hosts(:otherfullhost)
      @host2 = hosts(:anotherfullhost)
    end
  end

  test "user with edit host rights with update environments should change environments" do
    @request.env['HTTP_REFERER'] = hosts_path
    setup_multiple_environments
    assert @host1.environment == environments(:production)
    assert @host2.environment == environments(:production)
    post :update_multiple_environment, { :host_ids => [@host1.id, @host2.id],
      :environment => { :id => environments(:global_puppetmaster).id}},
      set_session_user.merge(:user => User.first.id)
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
      set_session_user.merge(:user => User.first.id)

    assert Host.find(@host1.id).environment == hostgroup.environment
    assert Host.find(@host2.id).environment == hostgroup.environment
  end

  test "user with edit host rights with update parameters should change parameters" do
    setup_multiple_environments
    @host1.host_parameters = [HostParameter.create(:name => "p1", :value => "yo")]
    @host2.host_parameters = [HostParameter.create(:name => "p1", :value => "hi")]
    post :update_multiple_parameters,
      {:name => { "p1" => "hello"},:host_ids => [@host1.id, @host2.id]},
      set_session_user.merge(:user => User.first.id)
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

  test "should get disabled hosts for a user with a fact_filter via json" do
    one = users(:one)
    one.roles << [roles(:manager)]
    fn  = FactName.create :name =>"architecture"
    ufact = UserFact.create :user => one, :fact_name => fn, :criteria => "="
    assert !(ufact.new_record?)

    get :disabled, {:format => "json"}, {:user => one.id}
    assert_response :success
  end

  test "when REMOTE_USER is provided and both authorize_login_delegation{,_api}
        are set, authentication should succeed w/o valid session cookies" do
    Setting[:authorize_login_delegation] = true
    Setting[:authorize_login_delegation_api] = true
    set_remote_user_to users(:admin)
    host = Host.first
    get :show, {:id => host.to_param, :format => 'json'}
    assert_response :success
    get :show, {:id => host.to_param}
    assert_response :success
  end

  test "if only authorize_login_delegation is set, REMOTE_USER should be
        ignored for API requests" do
    Setting[:signo_sso] = false
    Setting[:authorize_login_delegation] = true
    Setting[:authorize_login_delegation_api] = false
    set_remote_user_to users(:admin)
    host = Host.first
    get :show, {:id => host.to_param, :format => 'json'}
    assert_response 401
    get :show, {:id => host.to_param}
    assert_response :success
  end

  test "if both authorize_login_delegation{,_api} are unset,
        REMOTE_USER should ignored in all cases" do
    Setting[:signo_sso] = false
    Setting[:authorize_login_delegation] = false
    Setting[:authorize_login_delegation_api] = false
    set_remote_user_to users(:admin)
    host = Host.first
    get :show, {:id => host.to_param, :format => 'json'}
    assert_response 401
    get :show, {:id => host.to_param}
    assert_redirected_to "/users/login"
  end

  def set_remote_user_to user
    @request.env['REMOTE_USER'] = user.login
  end

  def test_submit_multiple_build
    assert !hosts(:one).build
    assert !hosts(:two).build
    post :submit_multiple_build, {:host_ids => [hosts(:one).id, hosts(:two).id]}, set_session_user
    assert_response :found
    assert_redirected_to hosts_path
    assert flash[:notice] == "The selected hosts will execute a build operation on next reboot"
    assert Host.find(hosts(:one)).build
    assert Host.find(hosts(:two)).build
  end

  def test_set_manage
    @request.env['HTTP_REFERER'] = edit_host_path @host
    assert @host.update_attribute :managed, false
    assert @host.errors.empty?
    put :toggle_manage, {:id => @host.name}, set_session_user
    assert_redirected_to :controller => :hosts, :action => :edit
    assert flash[:notice] == "Foreman now manages the build cycle for #{@host.name}"
  end

  def test_unset_manage
    @request.env['HTTP_REFERER'] = edit_host_path @host
    assert @host.update_attribute :managed, true
    assert @host.errors.empty?
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
    assert_difference "location.taxable_taxonomies.count", 17 do
      post :update_multiple_location, {
                                         :location => {:id => location.id, :optimistic_import => "yes"},
                                         :host_ids => Host.all.map(&:id)
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
    assert_difference "organization.taxable_taxonomies.count", 17 do
      post :update_multiple_organization, {
                                         :organization => {:id => organization.id, :optimistic_import => "yes"},
                                         :host_ids => Host.all.map(&:id)
                                         }, set_session_user
    end
  end

  test "can change sti type to valid subtype" do
    class Host::Valid < Host::Base ; end
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

  private
  def initialize_host
    User.current = users(:admin)
    disable_orchestration
    @host = Host.create(:name => "myfullhost",
                        :mac             => "aabbecddeeff",
                        :ip              => "2.3.4.99",
                        :domain_id          => domains(:mydomain).id,
                        :operatingsystem_id => operatingsystems(:redhat).id,
                        :architecture_id    => architectures(:x86_64).id,
                        :environment_id     => environments(:production).id,
                        :subnet_id          => subnets(:one).id,
                        :disk            => "empty partition",
                        :puppet_proxy_id    => smart_proxies(:puppetmaster).id,
                        :root_pass          => "123456789"
                       )
  end
end
