require 'test_helper'

class SystemsControllerTest < ActionController::TestCase
  setup :initialize_system

  def test_show
    get :show, {:id => System.first.name}, set_session_user
    assert_template 'show'
  end

  def test_create_invalid
    System.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    System.any_instance.stubs(:valid?).returns(true)
    post :create, {:system => {:name => "test"}}, set_session_user
    assert_redirected_to system_url(assigns('system'))
  end

  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should render 404 when system is not found" do
    get :show, {:id => "no.such.system"}, set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
    assert_template 'new'
  end

  test "should create new system" do
    assert_difference 'System.count' do
      post :create, { :commit => "Create",
        :system => {:name => "myotherfullsystem",
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
    assert_redirected_to system_url(assigns['system'])
  end

  test "should get edit" do
    get :edit, {:id => @system.name}, set_session_user
    assert_response :success
    assert_template 'edit'
  end

  test "should update system" do
    put :update, { :commit => "Update", :id => @system.name, :system => {:disk => "ntfs"} }, set_session_user
    @system = System.find(@system)
    assert_equal @system.disk, "ntfs"
  end

  def test_update_invalid
    System.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => System.first.name, :system => {}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    System.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => System.first.name, :system => {}}, set_session_user
    assert_redirected_to system_url(assigns(:system))
  end

  test "should destroy system" do
    assert_difference('System.count', -1) do
      delete :destroy, {:id => @system.name}, set_session_user
    end
    assert_redirected_to systems_url
  end

  test "externalNodes should render correctly when format text/html is given" do
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @system.name}, set_session_user
    assert_response :success
    assert_template :text => @system.info.to_yaml.gsub("\n","<br/>")
  end

  test "externalNodes should render yml request correctly" do
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @system.name, :format => "yml"}, set_session_user
    assert_response :success
    assert_template :text => @system.info.to_yaml
  end

  test "when system is saved after setBuild, the flash should inform it" do
    System.any_instance.stubs(:setBuild).returns(true)
    @request.env['HTTP_REFERER'] = systems_path

    get :setBuild, {:id => @system.name}, set_session_user
    assert_response :found
    assert_redirected_to systems_path
    assert_not_nil flash[:notice]
    assert flash[:notice] == "Enabled #{@system} for rebuild on next boot"
  end

  test "when system is not saved after setBuild, the flash should inform it" do
    System.any_instance.stubs(:setBuild).returns(false)
    @request.env['HTTP_REFERER'] = systems_path

    get :setBuild, {:id => @system.name}, set_session_user
    assert_response :found
    assert_redirected_to systems_path
    assert_not_nil flash[:error]
    assert flash[:error] =~ /Failed to enable #{@system} for installation/
  end

  def test_clone
    get :clone, {:id => System.first.name}, set_session_user
    assert assigns(:clone_system)
    assert_template 'new'
  end

  def test_clone_empties_fields
    get :clone, {:id => System.first.name}, set_session_user
    refute assigns(:system).name
    refute assigns(:system).ip
    refute assigns(:system).mac
  end

  def setup_user_and_system operation
    as_admin do
      @one             = users(:one)
      @one.domains.destroy_all
      @one.system_groups.destroy_all
      @one.user_facts.destroy_all
      @system1           = systems(:one)
      @system1.owner     = users(:admin)
      @system1.save!
      @system2           = systems(:two)
      @system2.owner     = users(:admin)
      @system2.save!
      @one.roles       = [Role.find_by_name('Anonymous'), Role.find_by_name("#{operation.capitalize} systems")]
    end
    System.per_page == 1000
    @request.session[:user] = @one.id
  end

  test 'user with edit system rights and domain is set should succeed in viewing system1' do
    setup_user_and_system "Edit"
    as_admin do
      @one.domains  = [domains(:mydomain)]
      @system1.update_attribute(:domain, domains(:mydomain))
      @system2.update_attribute(:domain, domains(:yourdomain))
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert_match /#{@system1.shortname}/, @response.body
  end

  test 'user with edit system rights and domain is set should fail to view system2' do
    setup_user_and_system "Edit"
    as_admin do
      @one.domains  = [domains(:mydomain)]
      @system1.domain = domains(:mydomain)
      @system2.domain = domains(:yourdomain)
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body !~ /#{@system2.name}/
  end

  test 'user with edit system rights and ownership is set should succeed in viewing system1' do
    setup_user_and_system "Edit"
    as_admin do
      @system1.owner = @one
      @system2.owner = users(:two)
      @one.filter_on_owner = true
      @one.save!
      @system1.save!
      @system2.save!
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body =~ /#{@system1.name}/
  end

  test 'user with edit system rights and ownership is set should fail to view system2' do
    setup_user_and_system "Edit"
    as_admin do
      @system1.owner = @one
      @system2.owner = users(:two)
      @one.filter_on_owner = true
      @one.save!
      @system1.save!
      @system2.save!
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body !~ /#{@system2.name}/
  end

  test 'user with edit system rights and system_group is set should succeed in viewing system1' do
    setup_user_and_system "Edit"
    as_admin do
      @system1.system_group = system_groups(:common)
      @system2.system_group = system_groups(:unusual)
      @one.system_groups  = [system_groups(:common)]
      @system1.save!
      @system2.save!
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body =~ /#{@system1.name}/
  end

  test 'user with edit system rights and system_group is set should fail to view system2' do
    setup_user_and_system "Edit"
    as_admin do
      @system1.system_group = system_groups(:common)
      @system2.system_group = system_groups(:unusual)
      @one.system_groups  = [system_groups(:common)]
      @system1.save!
      @system2.save!
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body !~ /#{@system2.name}/
  end

  test 'user with edit system rights and facts are set should succeed in viewing system1' do
    setup_user_and_system "Edit"
    as_admin do
      fn_id = FactName.find_or_create_by_name("architecture").id
      FactValue.create! :system => @system1, :fact_name_id => fn_id, :value    => "x86_64"
      FactValue.create! :system => @system2, :fact_name_id => fn_id, :value    => "i386"
      UserFact.create!  :user => @one,   :fact_name_id => fn_id, :criteria => "x86_64", :operator => "=", :andor => "or"
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body =~ /#{@system1.name}/
  end

  test 'user with edit system rights and facts are set should fail to view system2' do
    setup_user_and_system "Edit"
    as_admin do
      fn_id = FactName.find_or_create_by_name("architecture").id
      FactValue.create! :system => @system1, :fact_name_id => fn_id, :value    => "x86_64"
      FactValue.create! :system => @system2, :fact_name_id => fn_id, :value    => "i386"
      UserFact.create!  :user => @one,   :fact_name_id => fn_id, :criteria => "x86_64", :operator => "=", :andor => "or"
    end
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
    assert @response.body !~ /#{@system2.name}/
  end

  test 'user with view system rights should fail to edit system' do
    setup_user_and_system "View"
    get :edit, {:id => @system1.id}, set_session_user.merge(:user => @one.id)
    assert_equal @response.status, 403
  end

  test 'user with view system rights should should succeed in viewing systems' do
    setup_user_and_system "View"
    get :index, {}, set_session_user.merge(:user => @one.id)
    assert_response :success
  end

  test 'multiple without systems' do
    post :update_multiple_system_group, {}, set_session_user
    assert_redirected_to systems_url
    assert_equal "No systems selected", flash[:error]

    # now try to pass an invalid id
    post :update_multiple_system_group, {:system_ids => [-1], :system_names => ["no.such.system"]}, set_session_user

    assert_redirected_to systems_url
    assert_equal "No systems were found with that id or name", flash[:error]
  end

  test 'multiple system_group change by system ids' do
    @request.env['HTTP_REFERER'] = systems_path
    # check that we have systems and their system_group is empty
    systems = [systems(:one), systems(:two)]
    systems.each { |system| assert_nil system.system_group }

    system_group = system_groups(:unusual)
    post :update_multiple_system_group, { :system_ids => systems.map(&:id), :system_group => { :id => system_group.id } }, set_session_user

    # reloads systems
    systems.map! {|h| System.find(h.id)}
    systems.each { |system| assert_equal system_group, system.system_group }
  end


  test 'multiple system_group change by system names' do
    @request.env['HTTP_REFERER'] = systems_path
    system_names = %w{temp.yourdomain.net my5name.mydomain.net }
    # check that we have systems and their system_group is empty
    system_names.each do |name|
      system = System.find_by_name name
      assert_not_nil system
      assert_nil system.system_group
    end

    system_group = system_groups(:common)
    post :update_multiple_system_group, { :system_names => system_names, :system_group  => { :id => system_group.id} }, set_session_user

    system_names.each do |name|
      system = System.find_by_name name
      assert_not_nil system
      assert_equal system.system_group, system_group
    end
  end


  def setup_multiple_environments
    setup_user_and_system "edit"
    as_admin do
      @system1 = systems(:otherfullsystem)
      @system2 = systems(:anotherfullsystem)
    end
  end

  test "user with edit system rights with update environments should change environments" do
    @request.env['HTTP_REFERER'] = systems_path
    setup_multiple_environments
    assert @system1.environment == environments(:production)
    assert @system2.environment == environments(:production)
    post :update_multiple_environment, { :system_ids => [@system1.id, @system2.id],
      :environment => { :id => environments(:global_puppetmaster).id}},
      set_session_user.merge(:user => User.first.id)
    assert System.find(@system1.id).environment == environments(:global_puppetmaster)
    assert System.find(@system2.id).environment == environments(:global_puppetmaster)
  end

  test "should inherit the system_group environment if *inherit from system_group* selected" do
    @request.env['HTTP_REFERER'] = systems_path
    setup_multiple_environments
    assert @system1.environment == environments(:production)
    assert @system2.environment == environments(:production)

    system_group = system_groups(:common)
    system_group.environment = environments(:global_puppetmaster)
    system_group.save(:validate => false)

    @system1.system_group = system_group
    @system1.save(:validate => false)
    @system2.system_group = system_group
    @system2.save(:validate => false)

    params = { :system_ids => [@system1.id, @system2.id],
      :environment => { :id => 'inherit' } }

    post :update_multiple_environment, params,
      set_session_user.merge(:user => User.first.id)

    assert System.find(@system1.id).environment == system_group.environment
    assert System.find(@system2.id).environment == system_group.environment
  end

  test "user with edit system rights with update parameters should change parameters" do
    setup_multiple_environments
    @system1.system_parameters = [SystemParameter.create(:name => "p1", :value => "yo")]
    @system2.system_parameters = [SystemParameter.create(:name => "p1", :value => "hi")]
    post :update_multiple_parameters,
      {:name => { "p1" => "hello"},:system_ids => [@system1.id, @system2.id]},
      set_session_user.merge(:user => User.first.id)
    assert System.find(@system1.id).system_parameters[0][:value] == "hello"
    assert System.find(@system2.id).system_parameters[0][:value] == "hello"
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

  test "should get disabled systems" do
    get :disabled, {}, set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should get disabled systems for a user with a fact_filter" do
    one = users(:one)
    one.roles << [roles(:manager)]
    fn  = FactName.create :name =>"architecture"
    ufact = UserFact.create :user => one, :fact_name => fn, :criteria => "="
    assert !(ufact.new_record?)
    get :disabled, {:user => one.id}, set_session_user
    assert_response :success
  end

  test "if only authorize_login_delegation is set, REMOTE_USER should be
        ignored for API requests" do
    Setting[:signo_sso] = false
    Setting[:authorize_login_delegation] = true
    Setting[:authorize_login_delegation_api] = false
    set_remote_user_to users(:admin)
    User.current = nil # User.current is admin at this point (from initialize_system)
    system = System.first
    get :show, {:id => system.to_param, :format => 'json'}
    assert_response 401
    get :show, {:id => system.to_param}
    assert_response :success
  end

  test "if both authorize_login_delegation{,_api} are unset,
        REMOTE_USER should ignored in all cases" do
    Setting[:signo_sso] = false
    Setting[:authorize_login_delegation] = false
    Setting[:authorize_login_delegation_api] = false
    set_remote_user_to users(:admin)
    User.current = nil # User.current is admin at this point (from initialize_system)
    system = System.first
    get :show, {:id => system.to_param, :format => 'json'}
    assert_response 401
    get :show, {:id => system.to_param}
    assert_redirected_to "/users/login"
  end

  def set_remote_user_to user
    @request.env['REMOTE_USER'] = user.login
  end

  def test_submit_multiple_build
    assert !systems(:one).build
    assert !systems(:two).build
    post :submit_multiple_build, {:system_ids => [systems(:one).id, systems(:two).id]}, set_session_user
    assert_response :found
    assert_redirected_to systems_path
    assert flash[:notice] == "The selected systems will execute a build operation on next reboot"
    assert System.find(systems(:one)).build
    assert System.find(systems(:two)).build
  end

  def test_set_manage
    @request.env['HTTP_REFERER'] = edit_system_path @system
    assert @system.update_attribute :managed, false
    assert @system.errors.empty?
    put :toggle_manage, {:id => @system.name}, set_session_user
    assert_redirected_to :controller => :systems, :action => :edit
    assert flash[:notice] == "Foreman now manages the build cycle for #{@system.name}"
  end

  def test_unset_manage
    @request.env['HTTP_REFERER'] = edit_system_path @system
    assert @system.update_attribute :managed, true
    assert @system.errors.empty?
    put :toggle_manage, {:id => @system.name}, set_session_user
    assert_redirected_to :controller => :systems, :action => :edit
    assert flash[:notice] == "Foreman now no longer manages the build cycle for #{@system.name}"
  end

  test 'when ":restrict_registered_puppetmasters" is false, HTTP requests should be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = false
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @system.name, :format => "yml"}
    assert_response :success
  end

  test 'systems with a registered smart proxy on should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @system.name, :format => "yml"}
    assert_response :success
  end

  test 'systems without a registered smart proxy on should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['another.system'])
    get :externalNodes, {:name => @system.name, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'systems with a registered smart proxy and SSL cert should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @system.name, :format => "yml"}
    assert_response :success
  end

  test 'systems in trusted systems list and SSL cert should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    Setting[:trusted_puppetmaster_systems] = ['else.where']

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @system.name, :format => "yml"}
    assert_response :success
  end

  test 'systems without a registered smart proxy but with an SSL cert should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=another.system'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    get :externalNodes, {:name => @system.name, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'systems with an unverified SSL cert should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'FAILURE'
    get :externalNodes, {:name => @system.name, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'when "require_ssl_puppetmasters" and "require_ssl" are true, HTTP requests should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = true

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @system.name, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'when "require_ssl_puppetmasters" is true and "require_ssl" is false, HTTP requests should be able to get externalNodes' do
    User.current = nil
    # since require_ssl_puppetmasters is only applicable to HTTPS connections, both should be set
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, {:name => @system.name, :format => "yml"}
    assert_response :success
  end

  test 'authenticated users over HTTP should be able to get externalNodes' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['users.system'])
    get :externalNodes, {:name => @system.name, :format => "yml"}, set_session_user
    assert_response :success
  end

  test 'authenticated users over HTTPS should be able to get externalNodes' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['users.system'])
    @request.env['HTTPS'] = 'on'
    get :externalNodes, {:name => @system.name, :format => "yml"}, set_session_user
    assert_response :success
  end

  #Pessimistic - Location
  test "update multiple location fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    location = taxonomies(:location1)
    post :update_multiple_location, {
                                       :location => {:id => location.id, :optimistic_import => "no"},
                                       :system_ids => System.all.map(&:id)
                                       }, set_session_user
    assert_redirected_to :controller => :systems, :action => :index
    assert flash[:error] == "Cannot update Location to Location 1 because of mismatch in settings"
  end
  test "update multiple location does not update location of systems if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    location = taxonomies(:location1)
    assert_difference "location.systems.count", 0 do
      post :update_multiple_location, {
                                         :location => {:id => location.id, :optimistic_import => "no"},
                                         :system_ids => System.all.map(&:id)
                                         }, set_session_user
    end
  end
  test "update multiple location does not import taxable_taxonomies rows if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    location = taxonomies(:location1)
    assert_difference "location.taxable_taxonomies.count", 0 do
      post :update_multiple_location, {
                                         :location => {:id => location.id, :optimistic_import => "no"},
                                         :system_ids => System.all.map(&:id)
                                         }, set_session_user
    end
  end

  #Optimistic - Location
  test "update multiple location succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    location = taxonomies(:location1)
    post :update_multiple_location, {
                                       :location => {:id => location.id, :optimistic_import => "yes"},
                                       :system_ids => System.all.map(&:id)
                                       }, set_session_user
    assert_redirected_to :controller => :systems, :action => :index
    assert_equal "Updated systems: Changed Location", flash[:notice]
  end
  test "update multiple location updates location of systems if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    location = taxonomies(:location1)
    cnt_systems_location = location.systems.count
    assert_difference "location.systems.count", (System.count - cnt_systems_location) do
      post :update_multiple_location, {
                                         :location => {:id => location.id, :optimistic_import => "yes"},
                                         :system_ids => System.all.map(&:id)
                                         }, set_session_user
    end
  end
  test "update multiple location imports taxable_taxonomies rows if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    location = taxonomies(:location1)
    assert_difference "location.taxable_taxonomies.count", 15 do
      post :update_multiple_location, {
                                         :location => {:id => location.id, :optimistic_import => "yes"},
                                         :system_ids => System.all.map(&:id)
                                         }, set_session_user
    end
  end

  #Pessimistic - organization
  test "update multiple organization fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    organization = taxonomies(:organization1)
    post :update_multiple_organization, {
                                       :organization => {:id => organization.id, :optimistic_import => "no"},
                                       :system_ids => System.all.map(&:id)
                                       }, set_session_user
    assert_redirected_to :controller => :systems, :action => :index
    assert_equal "Cannot update Organization to Organization 1 because of mismatch in settings", flash[:error]
  end
  test "update multiple organization does not update organization of systems if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    organization = taxonomies(:organization1)
    assert_difference "organization.systems.count", 0 do
      post :update_multiple_organization, {
                                         :organization => {:id => organization.id, :optimistic_import => "no"},
                                         :system_ids => System.all.map(&:id)
                                         }, set_session_user
    end
  end
  test "update multiple organization does not import taxable_taxonomies rows if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    organization = taxonomies(:organization1)
    assert_difference "organization.taxable_taxonomies.count", 0 do
      post :update_multiple_organization, {
                                         :organization => {:id => organization.id, :optimistic_import => "no"},
                                         :system_ids => System.all.map(&:id)
                                         }, set_session_user
    end
  end

  #Optimistic - Organization
  test "update multiple organization succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    organization = taxonomies(:organization1)
    post :update_multiple_organization, {
                                       :organization => {:id => organization.id, :optimistic_import => "yes"},
                                       :system_ids => System.all.map(&:id)
                                       }, set_session_user
    assert_redirected_to :controller => :systems, :action => :index
    assert_equal "Updated systems: Changed Organization", flash[:notice]
  end
  test "update multiple organization updates organization of systems if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    organization = taxonomies(:organization1)
    cnt_systems_organization = organization.systems.count
    assert_difference "organization.systems.count", (System.count - cnt_systems_organization) do
      post :update_multiple_organization, {
                                         :organization => {:id => organization.id, :optimistic_import => "yes"},
                                         :system_ids => System.all.map(&:id)
                                         }, set_session_user
    end
  end
  test "update multiple organization imports taxable_taxonomies rows if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = systems_path
    organization = taxonomies(:organization1)
    assert_difference "organization.taxable_taxonomies.count", 15 do
      post :update_multiple_organization, {
                                         :organization => {:id => organization.id, :optimistic_import => "yes"},
                                         :system_ids => System.all.map(&:id)
                                         }, set_session_user
    end
  end

  test "can change sti type to valid subtype" do
    class System::Valid < System::Base ; end
    put :update, { :commit => "Update", :id => @system.name, :system => {:type => "System::Valid"} }, set_session_user
    @system = System::Base.find(@system.id)
    assert_equal "System::Valid", @system.type
  end

  test "cannot change sti type to invalid subtype" do
    old_type = @system.type
    put :update, { :commit => "Update", :id => @system.name, :system => {:type => "System::Notvalid"} }, set_session_user
    @system = System.find(@system.id)
    assert_equal old_type, @system.type
  end

  test "blank root password submitted does not erase existing password" do
    old_root_pass = @system.root_pass
    put :update, { :commit => "Update", :id => @system.name, :system => {:root_pass => ''} }, set_session_user
    @system = System.find(@system.id)
    assert_equal old_root_pass, @system.root_pass
  end

  test "blank BMC password submitted does not erase existing password" do
    bmc1 = @system.interfaces.build(:name => "bmc1", :mac => '52:54:00:b0:0c:fc', :type => 'Nic::BMC',
                      :ip => '10.0.1.101', :username => 'user1111', :password => 'abc123456', :provider => 'IPMI')
    assert bmc1.save
    old_password = bmc1.password
    put :update, { :commit => "Update", :id => @system.name, :system => {:interfaces_attributes => {"0" => {:id => bmc1.id, :password => ''} } } }, set_session_user
    @system = System.find(@system.id)
    assert_equal old_password, @system.interfaces.bmc.first.password
  end

  # To test that work-around for Rails bug - https://github.com/rails/rails/issues/11031
  test "BMC password updates successful even if attrs serialized field is the only dirty field" do
    bmc1 = @system.interfaces.build(:name => "bmc1", :mac => '52:54:00:b0:0c:fc', :type => 'Nic::BMC',
                      :ip => '10.0.1.101', :username => 'user1111', :password => 'abc123456', :provider => 'IPMI')
    assert bmc1.save
    new_password = "topsecret"
    put :update, { :commit => "Update", :id => @system.name, :system => {:interfaces_attributes => {"0" => {:id => bmc1.id, :password => new_password, :mac => bmc1.mac} } } }, set_session_user
    @system = System.find(@system.id)
    assert_equal new_password, @system.interfaces.bmc.first.password
  end

  test "index returns YAML output for rundeck" do
    get :index, {:format => 'yaml', :rundeck => true}, set_session_user
    systems = YAML.load(@response.body)
    assert !systems.empty?
    system = System.first
    assert_equal system.os.name, systems[system.name]["osName"]  # rundeck-specific field
  end

  test "show returns YAML output for rundeck" do
    system = System.first
    get :show, {:id => system.to_param, :format => 'yaml', :rundeck => true}, set_session_user
    yaml = YAML.load(@response.body)
    assert_kind_of Hash, yaml[system.name]
    assert_equal system.name, yaml[system.name]["systemname"]
    assert_equal system.os.name, yaml[system.name]["osName"]  # rundeck-specific field
  end

  private
  def initialize_system
    User.current = users(:admin)
    disable_orchestration
    @system = System.create(:name => "myfullsystem",
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
