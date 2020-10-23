require 'test_helper'
require 'pagelets_test_helper'
require 'nokogiri'

class HostsControllerTest < ActionController::TestCase
  include PageletsIsolation

  setup :initialize_host

  basic_pagination_rendered_test
  basic_pagination_per_page_test

  def host_attributes(host)
    known_attrs = HostsController.host_params_filter.accessible_attributes(HostsController.parameter_filter_context)
    host.attributes.except('id', 'created_at', 'updated_at').slice(*known_attrs)
  end

  test 'show' do
    get :show, params: { :id => Host.first.name }, session: set_session_user
    assert_template 'show'
  end

  test 'create_invalid' do
    Host.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :host => {:name => nil} }, session: set_session_user
    assert_template 'new'
  end

  test 'create_valid' do
    Host.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :host => {:name => "test"} }, session: set_session_user
    assert_redirected_to host_url(assigns('host'))
  end

  test "should get index" do
    get :index, session: set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should get csv index with data" do
    host = FactoryBot.create(:host, :with_hostgroup, :with_environment, :on_compute_resource, :with_reports)
    get :index, params: { :format => 'csv', :search => "name = #{host.name}" }, session: set_session_user
    assert_response :success
    buf = response.stream.instance_variable_get(:@buf)
    assert_equal "Name,Operatingsystem,Environment,Compute Resource Or Model,Hostgroup,Last Report\n", buf.next
    assert_equal "#{host.name},#{host.operatingsystem},#{host.environment},#{host.compute_resource.name},#{host.hostgroup},#{host.last_report}\n", buf.next
    assert_raises StopIteration do
      buf.next
    end
  end

  test "should include registered scope on index" do
    # remember the previous state
    old_scopes = HostsController.scopes_for(:index).dup

    scope_accessed = false
    HostsController.add_scope_for(:index) do |base_scope|
      scope_accessed = true
      base_scope
    end
    get :index, session: set_session_user
    assert_response :success
    assert_template 'index'
    assert scope_accessed

    # restore the previous state
    new_scopes = HostsController.scopes_for(:index)
    new_scopes.keep_if { |s| old_scopes.include?(s) }
  end

  test "should render 404 when host is not found" do
    get :show, params: { :id => "no.such.host" }, session: set_session_user
    assert_response :missing
    assert_template 'common/404'
  end

  test "should get new" do
    get :new, session: set_session_user
    assert_response :success
    assert_template 'new'
  end

  test "should create new host" do
    assert_difference 'Host.unscoped.count' do
      post :create, params: { :commit => "Create",
        :host => {:name => "myotherfullhost",
          :mac => "aabbecddee06",
          :ip => "2.3.4.125",
          :domain_id => domains(:mydomain).id,
          :operatingsystem_id => operatingsystems(:redhat).id,
          :architecture_id => architectures(:x86_64).id,
          :environment_id => environments(:production).id,
          :subnet_id => subnets(:one).id,
          :medium_id => media(:one).id,
          :pxe_loader => "Grub2 UEFI",
          :realm_id => realms(:myrealm).id,
          :disk => "empty partition",
          :puppet_proxy_id => smart_proxies(:puppetmaster).id,
          :root_pass => "xybxa6JUkz63w",
          :location_id => taxonomies(:location1).id,
          :organization_id => taxonomies(:organization1).id,
        },
       }, session: set_session_user
    end
    assert_redirected_to host_url(assigns['host'])
  end

  context "with libvirt" do
    let(:other_libvirt_compute_resource) do
      FactoryBot.create(:libvirt_cr, :locations => [taxonomies(:location2)])
    end
    let(:other_orgs_libvirt_compute_resource) do
      FactoryBot.create(:libvirt_cr, :organizations => [taxonomies(:organization2)])
    end
    let(:host_attrs) do
      {:name => "myotherfullhost",
        :mac => "aabbecddee06",
        :ip => "2.3.4.125",
        :domain_id => domains(:mydomain).id,
        :operatingsystem_id => operatingsystems(:redhat).id,
        :architecture_id => architectures(:x86_64).id,
        :environment_id => environments(:production).id,
        :subnet_id => subnets(:one).id,
        :medium_id => media(:one).id,
        :pxe_loader => "Grub2 UEFI",
        :realm_id => realms(:myrealm).id,
        :disk => "empty partition",
        :puppet_proxy_id => smart_proxies(:puppetmaster).id,
        :root_pass => "xybxa6JUkz63w",
        :location_id => taxonomies(:location1).id,
        :organization_id => taxonomies(:organization1).id,
      }
    end

    def setup
      Foreman::Model::Libvirt.any_instance.stubs(:test_connection).returns(true)
      # max_cpu_count fails
      Foreman::Model::Libvirt.any_instance.stubs(:max_cpu_count).returns(1)
      Fog.mock!
    end

    def teardown
      Fog.unmock!
    end

    test "should not create a new host when the compute_resource is not in same location" do
      host_attrs[:compute_resource_id] = other_libvirt_compute_resource.id
      assert_no_difference 'Host.unscoped.count' do
        post :create, params: { :commit => "Create", :host => host_attrs }, session: set_session_user
        assert_not assigns(:host).valid?
      end
    end

    test "should not create a new host when the compute_resource is not in same organization" do
      host_attrs[:compute_resource_id] = other_orgs_libvirt_compute_resource.id
      assert_no_difference 'Host.unscoped.count' do
        post :create, params: { :commit => "Create", :host => host_attrs }, session: set_session_user
        assert_not assigns(:host).valid?
      end
    end
  end

  test "should create new host with hostgroup inherited fields" do
    leftovers = Host.search_for('myotherfullhost').first
    refute leftovers
    hostgroup = hostgroups(:common)
    assert_difference 'Host.unscoped.count' do
      post :create, params: { :commit => "Create",
        :host => {:name => "myotherfullhost",
          :mac => "aabbecddee06",
          :ip => "2.3.4.125",
          :domain_id => domains(:mydomain).id,
          :hostgroup_id => hostgroup.id,
          :operatingsystem_id => operatingsystems(:redhat).id,
          :architecture_id => architectures(:x86_64).id,
          :subnet_id => subnets(:one).id,
          :medium_id => media(:one).id,
          :realm_id => realms(:myrealm).id,
          :disk => "empty partition",
          :root_pass => "xybxa6JUkz63w",
          :location_id => taxonomies(:location1).id,
          :organization_id => taxonomies(:organization1).id,
        },
      }, session: set_session_user
    end
    as_admin do
      new_host = Host.search_for('myotherfullhost').first
      assert new_host.environment.present?
      assert_equal hostgroup.environment, new_host.environment
      assert new_host.puppet_proxy.present?
      assert_equal hostgroup.puppet_proxy, new_host.puppet_proxy
    end
    assert_redirected_to host_url(assigns['host'])
  end

  test "should get edit" do
    get :edit, params: { :id => @host.name }, session: set_session_user
    assert_response :success
    assert_template 'edit'
  end

  test "should update host" do
    put :update, params: { :commit => "Update", :id => @host.name, :host => {:disk => "ntfs"} }, session: set_session_user
    @host = Host.find(@host.id)
    assert_equal @host.disk, "ntfs"
  end

  def test_update_invalid
    Host.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => Host.first.name, :host => {:disk => 'ntfs'} }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Host.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => Host.first.name, :host => {:name => "Updated_#{Host.first.name}"} }, session: set_session_user
    assert_redirected_to host_url(assigns(:host))
  end

  test "should destroy host" do
    assert_difference('Host.unscoped.count', -1) do
      delete :destroy, params: { :id => @host.name }, session: set_session_user
    end
    assert_redirected_to hosts_url
  end

  test "externalNodes should render correctly when format text/html is given" do
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, params: { :name => @host.name }, session: set_session_user
    assert_response :success
    as_admin { @enc = @host.info.to_yaml }
    assert_equal "<pre>#{ERB::Util.html_escape(@enc)}</pre>", response.body
  end

  test "externalNodes should render yml request correctly" do
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, params: { :name => @host.name, :format => "yml" }, session: set_session_user
    assert_response :success
    as_admin { @enc = @host.info.deep_stringify_keys.to_yaml(:line_width => -1) }
    assert_equal @enc, response.body
  end

  test "externalNodes should render YAML hashes correctly" do
    HostInfoProviders::PuppetInfo.any_instance.expects(:classes_info_hash).returns(
      'dhcp' => {
        'bootfiles' => [
          {'name' => 'foo', 'mount_point' => '/bar'}.with_indifferent_access,
          {'name' => 'john', 'mount_point' => '/doe'}.with_indifferent_access,
        ],
      }
    ).at_least_once

    get :externalNodes, params: { :name => @host.name, :format => "yml" }, session: set_session_user
    assert_response :success
    as_admin { @enc = @host.info.deep_stringify_keys.to_yaml }
    assert_equal @enc, response.body
  end

  test "when host is not saved after setBuild, the flash should inform it" do
    Host.any_instance.stubs(:setBuild).returns(false)
    @request.env['HTTP_REFERER'] = hosts_path

    put :setBuild, params: { :id => @host.name }, session: set_session_user
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
      put :setBuild, params: { :id => @host.name }, session: set_session_user
      assert_response :found
      assert_redirected_to hosts_path
      assert_not_nil flash[:success]
      assert flash[:success] == "Enabled #{@host} for rebuild on next boot"
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

      put :setBuild, params: { :id => @host.name, :host => {:build => '1'} }, session: set_session_user
      assert_response :found
      assert_redirected_to hosts_path
      assert_not_nil flash[:success]
      assert_equal(flash[:success], "Enabled #{@host} for reboot and rebuild")
    end

    test 'and reboot requested and reboot failed, the flash should inform it' do
      Host::Managed.any_instance.stubs(:setBuild).returns(true)
      # Setup a power mockup
      class PowerShmocker
        def reset
          false
        end
      end
      Host::Managed.any_instance.stubs(:power).returns(PowerShmocker.new)
      put :setBuild, params: { :id => @host.name, :host => {:build => '1'} }, session: set_session_user
      @host.power.reset
      assert_response :found
      assert_redirected_to hosts_path
      assert_not_nil flash[:success]
      assert_equal(flash[:success], "Enabled #{@host} for rebuild on next boot, but failed to power cycle the host")
    end

    test 'should render ajax_error when finding a vm has been faild' do
      ComputeResource.any_instance.stubs(:find_vm_by_uuid).raises(ActiveRecord::RecordNotFound)
      host = FactoryBot.create(:host, :with_hostgroup, :with_environment, :on_compute_resource)
      get :vm, params: { :id => host.id }, session: set_session_user
      expected_body = "<div class=\"alert alert-danger \">"\
                      "<span class=\"pficon pficon-error-circle-o \"></span>"\
                      " <span class=\"text\"><span data-original-title=\"Failure: ActiveRecord::RecordNotFound\" rel=\"twipsy\">"\
                      "Failure: ActiveRecord::RecordNotFound</span></span></div>\n"
      assert_equal expected_body, response.body
      assert_response :internal_server_error
    end

    test 'and reboot requested and reboot raised exception, the flash should inform it' do
      Host::Managed.any_instance.stubs(:setBuild).returns(true)
      put :setBuild, params: { :id => @host.name, :host => {:build => '1'} }, session: set_session_user
      assert_raise Foreman::Exception do
        @host.power.reset
      end
      assert_response :found
      assert_redirected_to hosts_path
      assert_not_nil flash[:success]
      assert_equal(flash[:success], "Enabled #{@host} for rebuild on next boot")
    end
  end

  def test_clone
    ComputeResource.any_instance.stubs(:vm_compute_attributes_for).returns({})
    get :clone, params: { :id => Host.first.name }, session: set_session_user
    assert assigns(:clone_host)
    assert_template 'clone'
  end

  def test_clone_empties_fields
    ComputeResource.any_instance.stubs(:vm_compute_attributes_for).returns({})
    get :clone, params: { :id => Host.first.name }, session: set_session_user
    refute assigns(:host).name
    refute assigns(:host).ip
    refute assigns(:host).mac
  end

  def test_clone_with_hostgroup
    ComputeResource.any_instance.stubs(:vm_compute_attributes_for).returns({})
    host = FactoryBot.create(:host, :with_hostgroup)
    get :clone, params: { :id => host.id }, session: set_session_user
    assert assigns(:clone_host)
    assert_template 'clone'
    assert_response :success
  end

  def setup_user(operation, type = 'hosts', filter = nil, user = :one)
    super
  end

  def setup_user_and_host(operation, filter = nil, &block)
    setup_user operation, 'hosts', filter, &block

    as_admin do
      @host1           = FactoryBot.build(:host)
      @host1.owner     = users(:admin)
      @host1.save!
      @host2           = FactoryBot.build(:host)
      @host2.owner     = users(:admin)
      @host2.save!
    end
    Host.per_page = 1000
    @request.session[:user] = @one.id
  end

  test 'user with view host rights and domain is set should succeed in viewing host1 but fail for host2' do
    setup_user_and_host "view", "domain_id = #{domains(:mydomain).id}"

    as_admin do
      @host1.primary_interface.update_attribute(:domain, domains(:mydomain))
      @host2.primary_interface.update_attribute(:domain, domains(:yourdomain))
    end
    get :index, session: set_session_user.merge(:user => @one.id)

    assert_response :success
    assert_match /#{@host1.shortname}/, @response.body
    refute_match /#{@host2.shortname}/, @response.body
  end

  test 'user with view host rights and ownership is set should succeed in viewing host1 but fail for host2' do
    setup_user_and_host "view", "owner_id = #{users(:one).id} and owner_type = User"
    as_admin do
      @host1.owner = @one
      @host2.owner = users(:two)
      @host2.organization = users(:two).organizations.first
      @host2.location = users(:two).locations.first
      @host1.save!
      @host2.save!
    end
    get :index, session: set_session_user.merge(:user => @one.id)
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
    get :index, session: set_session_user.merge(:user => @one.id)
    assert_response :success
    assert_match /#{@host1.name}/, @response.body
    refute_match /#{@host2.name}/, @response.body
  end

  test 'user with edit host rights and facts are set should succeed in viewing host1 but fail for host2' do
    setup_user_and_host "view", "facts.architecture = \"x86_64\""
    as_admin do
      fn_id = FactName.where(:name => "architecture").first_or_create.id
      FactValue.create! :host => @host1, :fact_name_id => fn_id, :value    => "x86_64"
      FactValue.create! :host => @host2, :fact_name_id => fn_id, :value    => "i386"
    end
    get :index, session: set_session_user.merge(:user => @one.id)
    assert_response :success
    assert_match /#{@host1.name}/, @response.body
    refute_match /#{@host2.name}/, @response.body
  end

  test 'user with view host rights should fail to edit host' do
    setup_user_and_host "view"
    get :edit, params: { :id => @host1.id }, session: set_session_user.merge(:user => @one.id)
    assert_equal @response.status, 403
  end

  test 'user with view_params rights should see parameters in a host' do
    host = FactoryBot.create(:host, :with_parameter)
    setup_user "edit"
    setup_user "view", "params"
    get :edit, params: { :id => host.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_not_nil response.body['Global Parameters']
  end

  test 'user without view_params rights should not see parameters in a host' do
    host = FactoryBot.create(:host, :with_parameter)
    setup_user "edit"
    get :edit, params: { :id => host.id }, session: set_session_user.merge(:user => users(:one).id)
    html_doc = Nokogiri::HTML(response.body)
    assert_not_nil html_doc.css('div#global_parameters_table')
  end

  test 'multiple without hosts' do
    post :update_multiple_hostgroup, session: set_session_user
    assert_redirected_to hosts_url
    assert_equal "No hosts selected", flash[:error]

    # now try to pass an invalid id
    post :update_multiple_hostgroup, params: { :host_ids => [-1], :host_names => ["no.such.host"] }, session: set_session_user

    assert_redirected_to hosts_url
    assert_equal "No hosts were found with that id, name or query filter", flash[:error]
  end

  test 'multiple hostgroup change by host ids' do
    @request.env['HTTP_REFERER'] = hosts_path
    # check that we have hosts and their hostgroup is empty
    hosts = FactoryBot.create_list(:host, 2)
    hosts.each { |host| assert_nil host.hostgroup }

    hostgroup = hostgroups(:unusual)
    post :update_multiple_hostgroup, params: { :host_ids => hosts.map(&:id), :hostgroup => { :id => hostgroup.id } }, session: set_session_user
    assert_response :redirect

    # reloads hosts
    as_admin do
      hosts.each { |host| assert_equal hostgroup, host.reload.hostgroup }
    end
  end

  test 'multiple hostgroup change by host names' do
    @request.env['HTTP_REFERER'] = hosts_path
    hosts = FactoryBot.create_list(:host, 2)
    host_names = hosts.map(&:name)
    # check that we have hosts and their hostgroup is empty
    host_names.each do |name|
      host = Host.find_by_name name
      assert_not_nil host
      assert_nil host.hostgroup
    end

    hostgroup = hostgroups(:common)
    post :update_multiple_hostgroup, params: { :host_names => host_names, :hostgroup => { :id => hostgroup.id} }, session: set_session_user
    assert_response :redirect

    host_names.each do |name|
      as_admin do
        host = Host.unscoped.find_by_name(name)
        assert_not_nil host
        assert_equal host.hostgroup, hostgroup
      end
    end
  end

  test "user with edit host rights with update owner should change owner" do
    @request.env['HTTP_REFERER'] = hosts_path
    setup_user_and_host "edit"
    assert_equal users(:admin).id_and_type, @host1.is_owned_by
    assert_equal users(:admin).id_and_type, @host2.is_owned_by
    post :update_multiple_owner, params: { :host_ids => [@host1.id, @host2.id],
      :owner => { :id => users(:one).id_and_type} },
      session: set_session_user.merge(:user => users(:admin).id)
    as_admin do
      assert_equal users(:one).id_and_type, @host1.reload.is_owned_by
      assert_equal users(:one).id_and_type, @host2.reload.is_owned_by
    end
  end

  def setup_multiple_compute_resource
    setup_user_and_host "edit"
    as_admin do
      @host1, @host2 = FactoryBot.create_list(:host, 2, :on_compute_resource)
    end
  end

  test "should change the power of multiple hosts" do
    @request.env['HTTP_REFERER'] = hosts_path
    setup_multiple_compute_resource

    params = { :host_ids => [@host1.id, @host2.id],
      :power => { :action => 'poweroff' } }

    power_mock = mock("power")
    power_mock.expects(:poweroff).twice
    Host::Managed.any_instance.stubs(:power).returns(power_mock)

    post :update_multiple_power_state, params: params,
      session: set_session_user.merge(:user => users(:admin).id)
  end

  test "find multiple hosts by filter query" do
    setup_user_and_host "edit"
    post :update_multiple_owner, params: { :search => "",
      :owner => { :id => users(:one).id_and_type}},
      session: set_session_user.merge(:user => users(:admin).id)
    as_admin do
      assert_equal users(:one).id_and_type, @host1.reload.is_owned_by
      assert_equal users(:one).id_and_type, @host2.reload.is_owned_by
    end
  end

  test "use filter query which generate a collection" do
    setup_user_and_host "edit"
    post :update_multiple_owner, params: { :search => "owner = #{users(:admin).login}",
      :owner => { :id => users(:one).id_and_type}},
      session: set_session_user.merge(:user => users(:admin).id)
    as_admin do
      assert_equal users(:one).id_and_type, @host1.reload.is_owned_by
      assert_equal users(:one).id_and_type, @host2.reload.is_owned_by
    end
  end

  test "use a filter query which generates empty collection" do
    setup_user_and_host "edit"
    post :update_multiple_owner, params: { :search => "owner = #{users(:one).login}",
      :owner => { :id => users(:one).id_and_type}},
      session: set_session_user.merge(:user => users(:admin).id)
    as_admin do
      assert_equal users(:admin).id_and_type, @host1.reload.is_owned_by
      assert_equal users(:admin).id_and_type, @host2.reload.is_owned_by
    end
  end

  test "use empty filter query when it exists in params" do
    setup_user_and_host "edit"
    post :update_multiple_owner, params: {:host_ids => [@host1.id], :search => "",
      :owner => { :id => users(:one).id_and_type}},
      session: set_session_user.merge(:user => users(:admin).id)
    as_admin do
      assert_equal users(:one).id_and_type, @host1.reload.is_owned_by
      assert_equal users(:one).id_and_type, @host2.reload.is_owned_by
    end
  end

  describe "setting puppet proxy on multiple hosts" do
    before do
      setup_user_and_host "edit"
      as_admin do
        @hosts = FactoryBot.create_list(:host, 2, :with_puppet)
      end
    end

    test "should change the puppet proxy" do
      @request.env['HTTP_REFERER'] = hosts_path

      proxy = as_admin { FactoryBot.build(:puppet_smart_proxy) }

      params = { :host_ids => @hosts.map(&:id),
                 :proxy => { :proxy_id => proxy.id } }

      post :update_multiple_puppet_proxy, params: params,
        session: set_session_user.merge(:user => users(:admin).id)

      assert_empty flash[:error]

      @hosts.each do |host|
        assert_nil host.reload.puppet_ca_proxy
      end
    end

    test "should clear the puppet proxy of multiple hosts" do
      @request.env['HTTP_REFERER'] = hosts_path

      params = { :host_ids => @hosts.map(&:id),
                 :proxy => { :proxy_id => "" } }

      post :update_multiple_puppet_proxy, params: params,
        session: set_session_user.merge(:user => users(:admin).id)

      assert_empty flash[:error]

      @hosts.each do |host|
        assert_nil host.reload.puppet_ca_proxy
      end
    end
  end

  describe "setting puppet ca proxy on multiple hosts" do
    before do
      setup_user_and_host "edit"
      as_admin do
        @hosts = FactoryBot.create_list(:host, 2, :with_puppet_ca)
      end
    end

    test "should change the puppet ca proxy" do
      @request.env['HTTP_REFERER'] = hosts_path

      proxy = as_admin { FactoryBot.create(:smart_proxy, :features => [FactoryBot.create(:feature, :puppetca)]) }

      params = { :host_ids => @hosts.map(&:id),
                 :proxy => { :proxy_id => proxy.id } }

      post :update_multiple_puppet_ca_proxy, params: params,
        session: set_session_user.merge(:user => users(:admin).id)

      assert_empty flash[:error]

      @hosts.each do |host|
        as_admin do
          assert_equal proxy, host.reload.puppet_ca_proxy
        end
      end
    end

    test "should clear the puppet ca proxy" do
      @request.env['HTTP_REFERER'] = hosts_path

      params = { :host_ids => @hosts.map(&:id),
                 :proxy => { :proxy_id => "" } }

      post :update_multiple_puppet_ca_proxy, params: params,
        session: set_session_user.merge(:user => users(:admin).id)

      assert_empty flash[:error]

      @hosts.each do |host|
        as_admin do
          assert_nil host.reload.puppet_ca_proxy
        end
      end
    end
  end

  def setup_multiple_parameters
    setup_user_and_host "edit"
    as_admin do
      @host1, @host2 = FactoryBot.create_list(:host, 2, :environment => environments(:production),
                                               :organization => users(:one).organizations.first,
                                               :location => users(:one).locations.first)
    end
  end

  test "user with edit host rights with update parameters should change parameters" do
    setup_multiple_parameters
    param1 = HostParameter.create(:name => "p1", :value => "yo")
    param2 = HostParameter.create(:name => "p1", :value => "hi")

    as_admin do
      @host1.host_parameters = [param1]
      @host2.host_parameters = [param2]
    end

    post :update_multiple_parameters, params: {
      :name => { "p1" => "hello"}, :host_ids => [@host1.id, @host2.id] },
      session: set_session_user.merge(:user => users(:admin).id)
    assert Host.find(@host1.id).host_parameters[0][:value] == "hello"
    assert Host.find(@host2.id).host_parameters[0][:value] == "hello"
  end

  test "parameter details should be html escaped" do
    hg = FactoryBot.build(:hostgroup, :name => "<script>alert('hacked')</script>")
    host = FactoryBot.create(:host, :with_puppetclass, :hostgroup => hg)
    FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'string',
      :default_value => "<script>alert('hacked!');</script>",
      :description => "<script>alert('hacked!');</script>",
      :puppetclass => host.puppetclasses.first)
    FactoryBot.create(:hostgroup_parameter, :hostgroup => hg)
    get :edit, params: { :id => host.name }, session: set_session_user
    refute response.body.include?("<script>alert(")
    assert response.body.include?("&lt;script&gt;alert(")
    assert_equal 3, response.body.scan("&lt;script&gt;alert(").size
  end

  test "should get errors" do
    get :errors, session: set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should get active" do
    get :active, session: set_session_user
    assert_response :success
    assert_template :partial => "_list"
    assert_template 'index'
  end

  test "should get out of sync" do
    get :out_of_sync, session: set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should get pending" do
    get :pending, session: set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should get disabled hosts" do
    get :disabled, session: set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should get disabled hosts for a user with a fact_filter" do
    one = users(:one)
    one.roles << [roles(:manager)]
    FactName.create :name => "architecture"
    get :disabled, session: set_session_user(one)
    assert_response :success
  end

  context 'authorize_login_delegation = true' do
    setup do
      @host = Host.first
      Setting[:authorize_login_delegation] = true
      Setting[:authorize_login_delegation_api] = false
      user = FactoryBot.create(:user, :admin, :with_mail, :auth_source => auth_sources(:external))
      set_remote_user_to user
      User.current = nil # User.current is admin at this point (from initialize_host)
    end

    test "REMOTE_USER should be ignored for API requests" do
      get :show, params: {:id => @host.to_param, :format => 'json'}
      assert_response 401
    end

    test "REMOTE_USER should be trusted for UI requests" do
      get :show, params: {:id => @host.to_param}
      assert_response :success
    end
  end

  context 'authorize_login_delegation = false' do
    setup do
      @host = Host.first
      Setting[:authorize_login_delegation] = false
      Setting[:authorize_login_delegation_api] = false
      set_remote_user_to users(:admin)
      User.current = nil # User.current is admin at this point (from initialize_host)
    end

    test "REMOTE_USER should ignored for API requests" do
      get :show, params: {:id => @host.to_param, :format => 'json'}
      assert_response 401
    end

    test "REMOTE_USER should trusted for UI requests" do
      get :show, params: {:id => @host.to_param}
      assert_redirected_to "/users/login"
    end
  end

  def set_remote_user_to(user)
    @request.env['HTTP_REMOTE_USER'] = user.login
  end

  context 'submit actions with multiple hosts' do
    setup do
      @host1, @host2 = FactoryBot.create_list(:host, 2, :managed)
    end

    test 'build without reboot' do
      assert !@host1.build
      assert !@host2.build
      multiple_hosts_submit_request('build', [@host1.id, @host2.id],
        'The selected hosts will execute a build operation on next reboot',
        {:host => { :build => 0 }})
      assert Host.find(@host1.id).build
      assert Host.find(@host2.id).build
    end

    test 'build with reboot' do
      power_mock = mock('power')
      power_mock.expects(:reset).twice.returns(nil)

      Host::Managed.any_instance.expects(:supports_power_and_running?).twice.returns(true)
      Host::Managed.any_instance.expects(:power).twice.returns(power_mock)
      assert !@host1.build
      assert !@host2.build
      multiple_hosts_submit_request('build', [@host1.id, @host2.id],
        'The selected hosts were enabled for reboot and rebuild',
        {:host => { :build => 1 }})
      assert Host.find(@host1.id).build
      assert Host.find(@host2.id).build
    end

    test 'destroy' do
      multiple_hosts_submit_request('destroy', [@host1.id, @host2.id], 'Destroyed selected hosts')
      assert Host.where(:id => [@host1.id, @host2.id]).empty?
    end

    test 'disable notifications' do
      multiple_hosts_submit_request('disable', [@host1.id, @host2.id], 'Disabled selected hosts')
      refute Host.find(@host1.id).enabled
      refute Host.find(@host2.id).enabled
    end

    test 'enable notifications' do
      multiple_hosts_submit_request('enable', [@host1.id, @host2.id], 'Enabled selected hosts')
      assert Host.find(@host1.id).enabled
      assert Host.find(@host2.id).enabled
    end

    def multiple_hosts_submit_request(method, ids, success, params = {})
      post :"submit_multiple_#{method}", params: params.merge({:host_ids => ids}), session: set_session_user
      assert_response :found
      assert_redirected_to hosts_path
      assert_equal success, flash[:success]
    end
  end

  def test_set_manage
    @request.env['HTTP_REFERER'] = edit_host_path @host
    as_admin { assert @host.update_attribute :managed, false }
    assert_empty @host.errors
    put :toggle_manage, params: { :id => @host.name }, session: set_session_user
    assert_redirected_to :controller => :hosts, :action => :edit
    assert flash[:success] == _("Foreman now manages the build cycle for %s") % @host.name
  end

  def test_unset_manage
    @request.env['HTTP_REFERER'] = edit_host_path @host
    as_admin { assert @host.update_attribute :managed, true }
    assert_empty @host.errors
    put :toggle_manage, params: { :id => @host.name }, session: set_session_user
    assert_redirected_to :controller => :hosts, :action => :edit
    assert flash[:success] == _("Foreman now no longer manages the build cycle for %s") % @host.name
  end

  test 'when ":restrict_registered_smart_proxies" is false, HTTP requests should be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_smart_proxies] = false
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, params: { :name => @host.name, :format => "yml" }
    assert_response :success
  end

  test 'hosts with a registered smart proxy on should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, params: { :name => @host.name, :format => "yml" }
    assert_response :success
  end

  test 'hosts without a registered smart proxy on should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = false

    Resolv.any_instance.stubs(:getnames).returns(['another.host'])
    get :externalNodes, params: { :name => @host.name, :format => "yml" }
    assert_equal 403, @response.status
  end

  test 'hosts with a registered smart proxy and SSL cert should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, params: { :name => @host.name, :format => "yml" }
    assert_response :success
  end

  test 'hosts in trusted hosts list and SSL cert should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true
    Setting[:trusted_hosts] = ['else.where']

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, params: { :name => @host.name, :format => "yml" }
    assert_response :success
  end

  test 'hosts with comma-separated SSL DN should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true
    Setting[:trusted_hosts] = ['foreman.example']

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=foreman.example,OU=PUPPET,O=FOREMAN,ST=North Carolina,C=US'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, params: { :name => @host.name, :format => "yml" }
    assert_response :success
  end

  test 'hosts with slash-separated SSL DN should get externalNodes successfully' do
    User.current = nil
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true
    Setting[:trusted_hosts] = ['foreman.linux.lab.local']

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = '/C=US/ST=NC/L=City/O=Example/OU=IT/CN=foreman.linux.lab.local/emailAddress=user@example.com'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, params: { :name => @host.name, :format => "yml" }
    assert_response :success
  end

  test 'hosts without a registered smart proxy but with an SSL cert should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=another.host'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    get :externalNodes, params: { :name => @host.name, :format => "yml" }
    assert_equal 403, @response.status
  end

  test 'hosts with an unverified SSL cert should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN'] = 'CN=else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'FAILURE'
    get :externalNodes, params: { :name => @host.name, :format => "yml" }
    assert_equal 403, @response.status
  end

  test 'when "require_ssl_smart_proxies" and "require_ssl" are true, HTTP requests should not be able to get externalNodes' do
    User.current = nil
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true
    SETTINGS[:require_ssl] = true

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, params: { :name => @host.name, :format => "yml" }
    assert_equal 403, @response.status
  end

  test 'when "require_ssl_smart_proxies" is true and "require_ssl" is false, HTTP requests should be able to get externalNodes' do
    User.current = nil
    # since require_ssl_smart_proxies is only applicable to HTTPS connections, both should be set
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    get :externalNodes, params: { :name => @host.name, :format => "yml" }
    assert_response :success
  end

  test 'authenticated users over HTTP should be able to get externalNodes' do
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['users.host'])
    get :externalNodes, params: { :name => @host.name, :format => "yml" }, session: set_session_user
    assert_response :success
  end

  test 'authenticated users over HTTPS should be able to get externalNodes' do
    Setting[:restrict_registered_smart_proxies] = true
    Setting[:require_ssl_smart_proxies] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['users.host'])
    @request.env['HTTPS'] = 'on'
    get :externalNodes, params: { :name => @host.name, :format => "yml" }, session: set_session_user
    assert_response :success
  end

  # Pessimistic - Location
  test "update multiple location fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    location = taxonomies(:location1)
    post :update_multiple_location, params: {
      :location => {:id => location.id, :optimistic_import => "no"},
      :host_ids => Host.pluck('hosts.id'),
    }, session: set_session_user
    assert_redirected_to :controller => :hosts, :action => :index
    assert flash[:error] == "Cannot update Location to Location 1 because of mismatch in settings"
  end
  test "update multiple location does not update location of hosts if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    location = taxonomies(:location1)
    assert_difference "location.hosts.count", 0 do
      post :update_multiple_location, params: {
        :location => {:id => location.id, :optimistic_import => "no"},
        :host_ids => Host.pluck('hosts.id'),
      }, session: set_session_user
    end
  end
  test "update multiple location does not import taxable_taxonomies rows if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    location = taxonomies(:location1)
    assert_difference "location.taxable_taxonomies.count", 0 do
      post :update_multiple_location, params: {
        :location => {:id => location.id, :optimistic_import => "no"},
        :host_ids => Host.pluck('hosts.id'),
      }, session: set_session_user
    end
  end

  # Optimistic - Location
  test "update multiple location updates location of hosts if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    location = taxonomies(:location1)
    cnt_hosts_location = location.hosts.count
    assert_difference "location.hosts.count", (Host.unscoped.count - cnt_hosts_location) do
      post :update_multiple_location, params: {
        :location => {:id => location.id, :optimistic_import => "yes"},
        :host_ids => Host.pluck('hosts.id'),
      }, session: set_session_user
    end
    assert_redirected_to :controller => :hosts, :action => :index
    assert_equal "Updated hosts: Changed Location", flash[:success]
  end
  test "update multiple location imports taxable_taxonomies rows if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    location = taxonomies(:location1)
    domain = FactoryBot.create(:domain, :locations => [taxonomies(:location2)])
    hosts = FactoryBot.create_list(:host, 2, :domain => domain,
                                    :environment => environments(:production),
                                    :location => taxonomies(:location2))
    assert_difference "location.taxable_taxonomies.count", 1 do
      post :update_multiple_location, params: {
        :location => {:id => location.id, :optimistic_import => "yes"},
        :host_ids => hosts.map(&:id),
      }, session: set_session_user
    end
  end

  # Pessimistic - organization
  test "update multiple organization fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    post :update_multiple_organization, params: {
      :organization => {:id => organization.id, :optimistic_import => "no"},
      :host_ids => Host.pluck('hosts.id'),
    }, session: set_session_user
    assert_redirected_to :controller => :hosts, :action => :index
    assert_equal "Cannot update Organization to Organization 1 because of mismatch in settings", flash[:error]
  end
  test "update multiple organization does not update organization of hosts if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    assert_difference "organization.hosts.count", 0 do
      post :update_multiple_organization, params: {
        :organization => {:id => organization.id, :optimistic_import => "no"},
        :host_ids => Host.pluck('hosts.id'),
      }, session: set_session_user
    end
  end
  test "update multiple organization does not import taxable_taxonomies rows if fails on pessimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    assert_difference "organization.taxable_taxonomies.count", 0 do
      post :update_multiple_organization, params: {
        :organization => {:id => organization.id, :optimistic_import => "no"},
        :host_ids => Host.pluck('hosts.id'),
      }, session: set_session_user
    end
  end

  # Optimistic - Organization
  test "update multiple organization succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    post :update_multiple_organization, params: {
      :organization => {:id => organization.id, :optimistic_import => "yes"},
      :host_ids => Host.pluck('hosts.id'),
    }, session: set_session_user
    assert_redirected_to :controller => :hosts, :action => :index
    assert_equal "Updated hosts: Changed Organization", flash[:success]
  end
  test "update multiple organization succeeds with search" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization1 = taxonomies(:organization1)
    organization2 = taxonomies(:organization2)
    hosts = FactoryBot.create_list(:host, 2, :managed, organization: organization1)

    post :update_multiple_organization, params: {
      organization: {id: organization2.id, optimistic_import: 'yes'},
      search: 'domain ~ example',
    }, session: set_session_user
    assert_redirected_to :controller => :hosts, :action => :index
    assert_equal "Updated hosts: Changed Organization", flash[:success]

    hosts = hosts.map(&:reload)
    assert hosts.all? { |host| host.organization == organization2 }
  end
  test "update multiple organization updates organization of hosts if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    cnt_hosts_organization = organization.hosts.count
    assert_difference "organization.hosts.count", (Host.unscoped.count - cnt_hosts_organization) do
      post :update_multiple_organization, params: {
        :organization => {:id => organization.id, :optimistic_import => "yes"},
        :host_ids => Host.pluck('hosts.id'),
      }, session: set_session_user
    end
  end
  test "update multiple organization imports taxable_taxonomies rows if succeeds on optimistic import" do
    @request.env['HTTP_REFERER'] = hosts_path
    organization = taxonomies(:organization1)
    domain = FactoryBot.create(:domain, :organizations => [taxonomies(:organization2)])
    hosts = FactoryBot.create_list(:host, 2, :domain => domain,
                                    :environment => environments(:production),
                                    :organization => taxonomies(:organization2))
    assert_difference "organization.taxable_taxonomies.count", 1 do
      post :update_multiple_organization, params: {
        :organization => { :id => organization.id, :optimistic_import => "yes"},
        :host_ids => hosts.map(&:id),
      }, session: set_session_user
    end
  end

  test "can change sti type to valid subtype" do
    class Host::Valid < Host::Managed; end
    put :update, params: { :commit => "Update", :id => @host.name, :host => {:type => "Host::Valid"} }, session: set_session_user
    @host = Host::Base.find(@host.id)
    assert_equal "Host::Valid", @host.type
  end

  test "cannot change sti type to invalid subtype" do
    old_type = @host.type
    put :update, params: { :commit => "Update", :id => @host.name, :host => {:type => "Host::Notvalid"} }, session: set_session_user
    @host = Host.find(@host.id)
    assert_equal old_type, @host.type
  end

  test "host update without root password in the params does not erase existing password" do
    old_root_pass = @host.root_pass
    put :update, params: { :commit => "Update", :id => @host.name, :host => {:name => @host.name} }, session: set_session_user
    @host = Host.find(@host.id)
    assert_equal old_root_pass, @host.root_pass
  end

  test 'blank root password submitted in host does erase existing password' do
    put :update, params: { :commit => "Update", :id => @host.name, :host => {:root_pass => '' } }, session: set_session_user
    @host = Host.find(@host.id)
    assert @host.root_pass.empty?
  end

  test "host should get bmc status" do
    @host.stubs(:bmc_proxy).returns(nil)
    @host.interfaces.create(:name => "bmc1", :mac => '52:54:00:b0:0c:fc', :type => 'Nic::BMC',
                      :ip => '10.0.1.101', :username => 'user1111', :password => 'abc123456', :provider => 'IPMI')
    @host.power.stubs(:state).returns("on")
    get :bmc, params: { :id => @host.id }, session: set_session_user
    assert_response :success
  end

  test "host update without BMC paasword in the params does not erase existing password" do
    bmc1 = @host.interfaces.build(:name => "bmc1", :mac => '52:54:00:b0:0c:fc', :type => 'Nic::BMC',
                      :ip => '10.0.1.101', :username => 'user1111', :password => 'abc123456', :provider => 'IPMI')
    assert bmc1.save
    old_password = bmc1.password
    put :update, params: { :commit => "Update", :id => @host.name, :host => {:interfaces_attributes => {"0" => {:id => bmc1.id} } } }, session: set_session_user
    @host = Host.find(@host.id)
    assert_equal old_password, @host.interfaces.bmc.first.password
  end

  test 'blank BMC password submitted in host does erase existing password' do
    bmc1 = @host.interfaces.build(:name => "bmc1", :mac => '52:54:00:b0:0c:fc', :type => 'Nic::BMC',
                      :ip => '10.0.1.101', :username => 'user1111', :password => 'abc123456', :provider => 'IPMI')
    assert bmc1.save
    put :update, params: { :commit => "Update", :id => @host.name, :host => {:interfaces_attributes => {"0" => {:id => bmc1.id, :password => ''} } } }, session: set_session_user
    @host = Host.find(@host.id)
    assert @host.interfaces.bmc.first.password.empty?
  end

  # To test that work-around for Rails bug - https://github.com/rails/rails/issues/11031
  test "BMC password updates successful even if attrs serialized field is the only dirty field" do
    bmc1 = @host.interfaces.build(:name => "bmc1", :mac => '52:54:00:b0:0c:fc', :type => 'Nic::BMC',
                      :ip => '10.0.1.101', :username => 'user1111', :password => 'abc123456', :provider => 'IPMI')
    assert bmc1.save
    new_password = "topsecret"
    put :update, params: { :commit => "Update", :id => @host.name, :host => {:interfaces_attributes => {"0" => {:id => bmc1.id, :password => new_password, :mac => bmc1.mac} } } }, session: set_session_user
    @host = Host.find(@host.id)
    assert_equal new_password, @host.interfaces.bmc.first.password
  end

  test "test non admin multiple action" do
    users(:restricted).organizations << taxonomies(:organization1)
    users(:restricted).locations << taxonomies(:location1)
    host = FactoryBot.create(:host, :organization => taxonomies(:organization1), :location => taxonomies(:location1), :owner => users(:restricted))
    setup_user 'edit', 'hosts', "owner_type = User and owner_id = #{users(:restricted).id}", :restricted
    host_ids = [host.id]
    # the ajax can be any of the multiple actions, toke multiple_parameters for example
    post :multiple_parameters, params: {:host_ids => host_ids}, session: set_session_user(:restricted), xhr: true
    assert_response :success
  end

  test "select multiple action with valid host_ids param should return a selection page" do
    host = FactoryBot.create(:host)
    host2 = FactoryBot.create(:host)
    host_ids = [host.id, host2.id]
    post :multiple_parameters, params: {:host_ids => host_ids}, session: set_session_user, xhr: true
    assert_response :success
    assert_includes response.body, host.name
    assert_includes response.body, host2.name
  end

  test "select multiple action with empty host_ids should redirect to hosts page" do
    post :multiple_parameters, params: {:host_ids => []}, session: set_session_user, xhr: true
    assert_response :redirect, hosts_path
    assert_not_nil flash[:error]
  end

  test "select multiple action with not exists host_ids should redirect to hosts page" do
    post :multiple_parameters, params: {:host_ids => [-1, 2]}, session: set_session_user, xhr: true
    assert_response :redirect, hosts_path
    assert_not_nil flash[:error]
  end

  test "#forget_status deletes a sub-status" do
    host = FactoryBot.create(:host)
    status = ::HostStatus::BuildStatus.create!(host_id: host.id)
    post :forget_status, params: {:id => host.id, :status => status.id}, session: set_session_user
    refute host.host_statuses.include?(status)
  end

  test "#disassociate shows error when used on non-CR host" do
    host = FactoryBot.create(:host)
    @request.env["HTTP_REFERER"] = hosts_path
    put :disassociate, params: { :id => host.to_param }, session: set_session_user
    assert_response :redirect, hosts_path
    assert_not_nil flash[:error]
  end

  test "#disassociate removes UUID and CR association from host" do
    host = FactoryBot.create(:host, :on_compute_resource)
    @request.env["HTTP_REFERER"] = hosts_path
    put :disassociate, params: { :id => host.to_param }, session: set_session_user
    assert_response :redirect, hosts_path
    host.reload
    refute host.uuid
    refute host.compute_resource_id
  end

  test "#host update shouldn't diassociate from VM" do
    require 'fog/ovirt/models/compute/quota'
    hostgroup = FactoryBot.create(:hostgroup, :with_environment, :with_subnet, :with_domain, :with_os)
    compute_resource = compute_resources(:ovirt)
    quota = Fog::Ovirt::Compute::Quota.new({ :id => '1', :name => "Default" })
    client_mock = mock.tap { |m| m.stubs(datacenters: [], quotas: [quota]) }
    compute_resource.stubs(:client).returns(client_mock)
    compute_resource.update(:locations => hostgroup.locations, :organizations => hostgroup.organizations)
    host = FactoryBot.create(:host, :hostgroup => hostgroup, :compute_resource => compute_resource)
    host_attributes = host.attributes
    host_attributes.delete("compute_resource_id")
    put :update, params: { :commit => "Update", :id => host.id, :host => host_attributes}, session: set_session_user
    assert_response :redirect
    host.reload
    assert host.compute_resource_id
  end

  test '#update_multiple_disassociate' do
    host = FactoryBot.create(:host, :on_compute_resource)
    post :update_multiple_disassociate, params: { :host_ids => [host.id], :host_names => [host.name] }, session: set_session_user
    assert_response :redirect, hosts_path
    assert_not_nil flash[:success]
    host.reload
    refute host.uuid
    refute host.compute_resource_id
  end

  test '#multiple_disassociate with vm' do
    host = FactoryBot.create(:host, :on_compute_resource)
    post :multiple_disassociate, params: { :host_ids => [host.id], :host_names => [host.name] }, session: set_session_user
    assert_equal 1, assigns(:non_physical_hosts).count
    assert_equal 0, assigns(:physical_hosts).count
  end

  test '#multiple_disassociate with physical host' do
    host = FactoryBot.create(:host)
    post :multiple_disassociate, params: { :host_ids => [host.id], :host_names => [host.name] }, session: set_session_user
    assert_equal 0, assigns(:non_physical_hosts).count
    assert_equal 1, assigns(:physical_hosts).count
  end

  test '#review_before_build' do
    HostBuildStatus.any_instance.stubs(:host_status).returns(true)
    HostBuildStatus.any_instance.stubs(:check_all_statuses).returns(true)
    get :review_before_build, params: {:id => @host.name}, session: set_session_user, xhr: true
    assert_response :success
    assert_template 'review_before_build'
  end

  describe '#template_used' do
    setup do
      @host.setBuild
      ActiveRecord::Base.any_instance.expects(:destroy).never
      ActiveRecord::Base.any_instance.expects(:save).never
      @attrs = host_attributes(@host)
    end

    test 'returns templates with interfaces' do
      nic = FactoryBot.build(:nic_managed, :host => @host)
      @attrs[:interfaces_attributes] = nic.attributes.except 'updated_at', 'created_at', 'attrs'
      put :template_used, params: {:provisioning => 'build', :host => @attrs, :id => @host.id }, session: set_session_user, xhr: true
      assert_response :success
      assert_template :partial => '_provisioning'
    end

    test 'returns templates with host parameters' do
      @attrs[:host_parameters_attributes] = {'0' => {:name => 'foo', :value => 'bar', :id => '34'}}
      put :template_used, params: {:provisioning => 'build', :host => @attrs }, session: set_session_user
      assert_response :success
      assert_template :partial => '_provisioning'
    end

    test 'does not save has_many relations on existing hosts' do
      @attrs[:config_group_ids] = [config_groups(:one).id]
      put :template_used, params: {:provisioning => 'build', :host => @attrs, :id => @host.id }, session: set_session_user, xhr: true
      assert_response :success
      assert_template :partial => '_provisioning'
    end

    test 'shows templates for image provisioning' do
      image = compute_resources(:one).images.first
      @attrs[:compute_resource_id] = compute_resources(:one).id
      @attrs[:operatingsystem_id] = image.operatingsystem.id
      @attrs[:compute_attributes] ||= {}
      @attrs[:compute_attributes][compute_resources(:one).image_param_name] = image.uuid
      put :template_used, params: {:provisioning => 'image', :host => @attrs }, session: set_session_user, xhr: true
      assert_response :success
      assert_template :partial => '_provisioning'
      assert_includes response.body, 'MyFinish'
    end
  end

  test 'process_taxonomy renders a host from the params correctly' do
    nic = FactoryBot.build(:nic_managed, :host => @host)
    attrs = host_attributes(@host)
    attrs[:interfaces_attributes] = nic.attributes.except 'updated_at', 'created_at', 'attrs'
    ActiveRecord::Base.any_instance.expects(:destroy).never
    ActiveRecord::Base.any_instance.expects(:save).never
    put :process_taxonomy, params: { :host => attrs }, session: set_session_user, xhr: true
    assert_response :success
    assert response.body.include?(nic.attributes["mac"])
    assert_template :partial => '_form'
  end

  context 'test submit multiple rebuild config' do
    def test_submit_multiple_rebuild_config_optimistic
      @request.env['HTTP_REFERER'] = hosts_path
      Host.any_instance.expects(:recreate_config).returns({"TFTP" => true, "DHCP" => true, "DNS" => true})
      h = as_admin { FactoryBot.create(:host) }

      post :submit_rebuild_config, params: { :host_ids => [h.id] }, session: set_session_user

      assert_response :found
      assert_redirected_to hosts_path
      assert_not_nil flash[:success]
    end

    def test_submit_multiple_rebuild_config_pessimistic
      @request.env['HTTP_REFERER'] = hosts_path
      Host.any_instance.expects(:recreate_config).returns({"TFTP" => false, "DHCP" => false, "DNS" => false})
      h = as_admin { FactoryBot.create(:host) }

      post :submit_rebuild_config, params: { :host_ids => [h.id] }, session: set_session_user

      assert_response :found
      assert_redirected_to hosts_path
      assert_not_nil flash[:error]
    end
  end

  context 'openstack-fog.mock!' do
    setup do
      Fog.mock!
    end

    teardown { Fog.unmock! }

    test "#schedulerHintFilterSelected applies #scheduler_hint form for raw" do
      post :scheduler_hint_selected, params: { :host => {:compute_attributes => { :scheduler_hint_filter => "Raw"}, :compute_resource_id => compute_resources(:openstack).id }}, session: set_session_user, xhr: true
      assert_response :success
      assert_template :partial => 'compute_resources_vms/form/openstack/scheduler_filters/_raw'
    end
  end

  context 'Fog.mock!' do
    setup do
      Fog.mock!
      Foreman::Model::Libvirt.any_instance.stubs(:hypervisor).returns(stub(:hypervisor))
      Foreman::Model::Libvirt.any_instance.expects(:max_cpu_count).returns(10)
      Foreman::Model::Libvirt.any_instance.expects(:max_memory).returns(10000000000)
    end

    teardown { Fog.unmock! }

    test '#process_hostgroup changes compute attributes' do
      group1 = FactoryBot.create(:hostgroup, :compute_profile => compute_profiles(:one))
      host = FactoryBot.build_stubbed(:host, :managed, :on_compute_resource)
      # remove unneeded expectation to :queue_compute
      host.unstub(:queue_compute)
      host.hostgroup = group1
      host.compute_resource = compute_resources(:one)
      host.compute_profile = compute_profiles(:one)
      host.set_compute_attributes

      group2 = FactoryBot.create(:hostgroup, :compute_profile => compute_profiles(:two), :compute_resource => compute_resources(:one))

      attrs = host_attributes(host)
      attrs['hostgroup_id'] = group2.id
      attrs.delete 'compute_profile_id'

      put :process_hostgroup, params: { :host => attrs }, session: set_session_user, xhr: true

      assert_response :success
      assert_template :partial => '_form'
      assert_select 'input', {:name => 'host[compute_attributes][cpus]'}
    end

    test '#process_hostgroup does not change compute attributes if compute profile selected manually' do
      group1 = FactoryBot.create(:hostgroup, :compute_profile => compute_profiles(:one))
      host = FactoryBot.build_stubbed(:host, :managed, :on_compute_resource)
      # remove unneeded expectation to :queue_compute
      host.unstub(:queue_compute)
      host.hostgroup = group1
      host.compute_resource = compute_resources(:one)
      host.compute_profile = compute_profiles(:one)
      host.set_compute_attributes

      group2 = FactoryBot.create(:hostgroup, :compute_profile => compute_profiles(:two), :compute_resource => compute_resources(:one))

      attrs = host_attributes(host)
      attrs['hostgroup_id'] = group2.id
      attrs['compute_attributes'] = { 'cpus' => 3 }
      attrs.delete 'uuid'

      put :process_hostgroup, params: { :host => attrs }, session: set_session_user, xhr: true

      assert_response :success
      assert_template :partial => '_form'
      assert_select 'input', {:name => 'host[compute_attributes][cpus]'}
    end

    test '#compute_resource_selected renders compute tab without compute profile' do
      get :compute_resource_selected, params: { :host => {:compute_resource_id => compute_resources(:one).id}}, session: set_session_user, xhr: true
      assert_response :success
      assert_template :partial => '_compute'
      assert_select 'input', {:name => 'host[compute_attributes][cpus]'}
    end

    test '#compute_resource_selected renders compute tab with explicit compute profile' do
      get :compute_resource_selected, params: { :host => {:compute_resource_id => compute_resources(:one).id, :compute_profile_id => compute_profiles(:two).id}}, session: set_session_user, xhr: true
      assert_response :success
      assert_template :partial => '_compute'
      assert_select 'input', {:name => 'host[compute_attributes][cpus]'}
    end

    test '#compute_resource_selected renders compute tab with hostgroup\'s compute profile' do
      group = FactoryBot.build(:hostgroup, :compute_profile => compute_profiles(:two))
      get :compute_resource_selected, params: { :host => {:compute_resource_id => compute_resources(:one).id, :hostgroup_id => group.id}}, session: set_session_user, xhr: true
      assert_response :success
      assert_template :partial => '_compute'
      assert_select 'input', {:name => 'host[compute_attributes][cpus]'}
    end

    test '#compute_resource_selected renders compute tab with hostgroup parent\'s compute profile' do
      parent = FactoryBot.create(:hostgroup, :compute_profile => compute_profiles(:two))
      group = FactoryBot.build(:hostgroup, :parent => parent)
      get :compute_resource_selected, params: { :host => {:compute_resource_id => compute_resources(:one).id, :hostgroup_id => group.id}}, session: set_session_user, xhr: true
      assert_response :success
      assert_template :partial => '_compute'
      assert_select 'input', {:name => 'host[compute_attributes][cpus]'}
    end
  end

  test '#process_hostgroup such that it autofils values for an existing host' do
    group1 = FactoryBot.create(:hostgroup, :compute_profile => compute_profiles(:two))
    host = FactoryBot.create(:host, :type => "Host::Base", :hostgroup => group1)
    # remove unneeded expectation to :queue_compute
    host.unstub(:queue_compute)
    host.hostgroup = group1

    attrs = host_attributes(host)
    attrs["id"] = host.id

    put :process_hostgroup, params: { :host => attrs }, session: set_session_user, xhr: true
    assert_response :success
    assert_template :partial => '_form'
  end

  test '#process_hostgroup works on Host subclasses' do
    class Host::Test < Host::Base; end
    user = FactoryBot.create(:user, :with_mail, :admin => false)
    FactoryBot.create(:filter, :role => roles(:create_hosts), :permissions => Permission.where(:name => ['edit_hosts', 'view_hosts']))
    user.roles << roles(:create_hosts)
    user.save!
    hostgroup = FactoryBot.create(:hostgroup)
    host = FactoryBot.create(:host, :type => "Host::Test", :hostgroup => hostgroup)
    host.stubs(:set_hostgroup_defaults)
    host.stubs(:set_compute_attributes)
    host.stubs(:architecture)
    host.stubs(:operatingsystem)
    host.stubs(:environment)
    host.stubs(:domain)
    host.stubs(:subnet)
    host.stubs(:compute_profile)
    host.stubs(:realm)
    attrs = host_attributes(host)
    attrs[:id] = host.id
    attrs[:hostgroup_id] = hostgroup.id
    put :process_hostgroup, params: { :host => attrs }, session: set_session_user(user), xhr: true
    assert_response :success
  end

  test '#compute_resource_selected returns 404 without compute_resource_id' do
    get :compute_resource_selected, params: { :host => {} }, session: set_session_user, xhr: true
    assert_response :not_found
  end

  test '#compute_resource_selected returns 404 without valid compute resource' do
    user = FactoryBot.build(:user, :with_mail, :admin => false)
    FactoryBot.create(:filter, :role => roles(:create_hosts), :permissions => Permission.where(:name => ['edit_hosts', 'view_hosts']))
    user.roles << roles(:create_hosts)
    user.save!

    parent = FactoryBot.create(:hostgroup, :compute_profile => compute_profiles(:two))
    group = FactoryBot.build(:hostgroup, :parent => parent)
    get :compute_resource_selected, params: { :host => {:compute_resource_id => compute_resources(:one).id, :hostgroup_id => group.id}}, session: set_session_user(user), xhr: true
    assert_response :not_found
  end

  test '#interfaces applies compute profile and returns interfaces partial' do
    modifier = mock('InterfaceMerge')
    InterfaceMerge.expects(:new).with().returns(modifier)
    Host::Managed.any_instance.expects(:apply_compute_profile).with(modifier)
    get :interfaces, params: { :host => {:compute_resource_id => compute_resources(:one).id, :compute_profile_id => compute_profiles(:one).id}}, session: set_session_user, xhr: true
    assert_response :success
    assert_template :partial => '_interfaces'
  end

  test 'failed cancelBuild shows errors' do
    @request.env['HTTP_REFERER'] = hosts_path
    HostsController.any_instance.stubs(:resource_finder).returns(@host)
    @host.errors[:test] << 'my error'
    @host.interfaces = [] # force save failure
    get :cancelBuild, params: { id: @host.name }, session: set_session_user

    assert_response :redirect
    assert_match(/Failed to cancel/, flash[:error])
    assert_match(/following errors/, flash[:error])
    assert_match(/host must have/, flash[:error])
  end

  test "should create matcher for host turning into managed" do
    original_host = Host::Base.create(:name => 'test', :domain => FactoryBot.create(:domain))
    lookup_key = FactoryBot.create(:lookup_key)
    host = original_host.becomes(::Host::Managed)
    host.type = 'Host::Managed'
    host.managed = true
    host.primary_interface.managed = true
    host.lookup_values.build({"match" => "fqdn=#{host.fqdn}", "value" => '4', "lookup_key_id" => lookup_key.id, "host_or_hostgroup" => host})
    assert_valid host.lookup_values.first
  end

  describe '#update' do
    context 'with vmware' do
      setup do
        Fog.mock!

        uuid = '5032c8a5-9c5e-ba7a-3804-832a03e16381' # from fog mock data
        compute_resource = FactoryBot.create(:vmware_cr, uuid: 'Solutions')
        compute_resource = ComputeResource.find(compute_resource.id)
        @vmware_host = FactoryBot.create(:host, :managed, compute_resource: compute_resource,
                                                  uuid: uuid,
                                                  provision_method: 'image')
      end

      teardown { Fog.unmock! }

      it 'allows edit disk size' do
        scsi_controllers = [{ 'type' => 'VirtualLsiLogicController', 'key' => 1000 }]
        volume_params = {
          'thin' => true,
          'name' => 'Hard disk',
          'mode' => 'persistent',
          'controllerKey' => 1000,
          'size' => 10485760,
          'sizeGb' => 12,
        }
        volume_attributes = volume_params.clone.tap do |attrs|
          attrs['controller_key'] = attrs.delete('controllerKey')
          attrs['size_gb'] = attrs.delete('sizeGb')
        end

        Host::Managed.any_instance.expects('compute_attributes=').with(
          'scsi_controllers' => scsi_controllers,
          'volumes_attributes' => { '0' => volume_attributes }
        )

        put :update, params: {
          commit: "Update",
          id: @vmware_host.name,
          host: { compute_attributes: { scsi_controllers: { 'scsiControllers' => scsi_controllers, 'volumes' => [volume_params] }.to_json } },
        }, session: set_session_user

        assert_redirected_to host_path(@vmware_host.to_param)
      end
    end
  end

  describe '#ipmi_boot' do
    setup do
      @request.env['HTTP_REFERER'] = host_path(@host.id)
      setup_user 'ipmi_boot', 'hosts'
    end

    test 'returns error for non-admin user if BMC is not available' do
      put :ipmi_boot, params: { :id => @host.id, :ipmi_device => 'bios' },
        session: set_session_user.merge(:user => @one.id)
      assert_match(/No BMC NIC available for host/, flash[:error])
      assert_redirected_to host_path(@host.id)
    end

    test 'responds correctly for non-admin user if BMC is available' do
      Host::Managed.any_instance.expects(:ipmi_boot).with('bios').returns(true)
      put :ipmi_boot, params: { :id => @host.id, :ipmi_device => 'bios' },
        session: set_session_user.merge(:user => @one.id)
      assert_match(/#{@host.name} now boots from BIOS/, flash[:success])
      assert_redirected_to host_path(@host.id)
    end
  end

  describe '#hostgroup_or_environment_selected' do
    test 'choosing only one of hostgroup or environment renders classes' do
      post :hostgroup_or_environment_selected, params: {
        :host_id => nil,
        :host => {
          :environment_id => Environment.unscoped.first.id,
        },
      }, session: set_session_user, xhr: true
      assert_response :success
      assert_template :partial => 'puppetclasses/_class_selection'
    end

    test 'choosing both hostgroup and environment renders classes' do
      post :hostgroup_or_environment_selected, params: {
        :host_id => @host.id,
        :host => {
          :environment_id => Environment.unscoped.first.id,
          :hostgroup_id => Hostgroup.unscoped.first.id,
        },
      }, session: set_session_user, xhr: true
      assert_response :success
      assert_template :partial => 'puppetclasses/_class_selection'
    end

    test 'should not escape lookup values on environment change' do
      host = FactoryBot.create(:host, :with_environment, :with_puppetclass)

      host.environment.locations = [host.location]
      host.environment.organizations = [host.organization]

      lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :key_type => 'array',
                                     :default_value => ['a', 'b'], :override => true, :puppetclass => host.puppetclasses.first)
      lookup_value = FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :match => "fqdn=#{host.fqdn}", :value => ["c", "d"])

      # sending exactly what the host form would send which is lookup_value.value_before_type_cast
      lk = {"lookup_values_attributes" => {lookup_key.id.to_s => {"value" => lookup_value.value_before_type_cast, "id" => lookup_value.id, "lookup_key_id" => lookup_key.id, "_destroy" => false}}}

      params = {
        host_id: host.id,
        host: host.attributes.merge(lk),
      }

      # environment change calls puppetclass_parameters which caused the extra escaping
      post :puppetclass_parameters, params: params, session: set_session_user, xhr: true

      # if this was escaped during refresh_host the value in response.body after unescapeHTML would include "[\\\"c\\\",\\\"d\\\"]"
      assert_includes CGI.unescapeHTML(response.body), "[\"c\",\"d\"]"
    end
  end

  context '#preview_host_collection' do
    test 'should list hosts' do
      host = FactoryBot.create(:host, :managed)
      get :preview_host_collection, params: { :q => '' }, session: set_session_user, xhr: true
      assert_response :success
      response = JSON.parse(@response.body)
      assert_kind_of Array, response
      assert_kind_of Hash, response.first
      expected = {'id' => host.id, 'name' => host.name}
      assert_includes response, expected
    end

    test 'should find a host by name' do
      host1 = FactoryBot.create(:host, :managed, :hostname => 'aaaaaaa')
      host2 = FactoryBot.create(:host, :managed, :hostname => 'zzzzzzz')
      get :preview_host_collection, params: { :q => 'aaaaaaa' }, session: set_session_user, xhr: true
      assert_response :success
      response = JSON.parse(@response.body)
      expected = {'id' => host1.id, 'name' => host1.name}
      not_expected = {'id' => host2.id, 'name' => host2.name}
      assert_includes response, expected
      assert_not_includes response, not_expected
    end
  end

  context 'with pagelets' do
    setup do
      @controller.prepend_view_path File.expand_path('../static_fixtures', __dir__)
      Pagelets::Manager.add_pagelet('hosts/show', :main_tabs,
        :name => 'TestTab',
        :id => 'my-special-id',
        :partial => 'views/test')
    end

    test '#show renders a pagelet tab' do
      get :show, params: {:id => Host.first.name}, session: set_session_user
      assert @response.body.match /id='my-special-id'/
    end
  end

  context 'redirection after destroying a host' do
    setup do
      @hostgroup1 = FactoryBot.create(:hostgroup, :with_parent, :with_domain, :with_os)
      @hostgroup2 = FactoryBot.create(:hostgroup, :with_parent, :with_domain, :with_os)
      @managed_host1 = FactoryBot.create(:host, :managed, :hostgroup => @hostgroup1)
      @managed_host2 = FactoryBot.create(:host, :managed, :hostgroup => @hostgroup1)
      @managed_host3 = FactoryBot.create(:host, :managed, :hostgroup => @hostgroup2)
    end

    test "after deleting host search filter should remain as it is" do
      hosts_search_path = hosts_path(search: "hostgroup_name = #{@hostgroup1.name}")
      @request.session["redirect_to_url_hosts"] = hosts_search_path

      delete :destroy, params: { :id => @managed_host1.id }, session: set_session_user
      assert_redirected_to hosts_search_path
      assert_not Host.exists?(@managed_host1.id)
    end

    test "after deleting host, it should redirect to hosts page if no session" do
      delete :destroy, params: { :id => @managed_host1.id }, session: set_session_user
      assert_redirected_to hosts_path
      assert_not Host.exists?(@managed_host1.id)
    end
  end

  context 'interfaces' do
    test 'Taxonomy scope for interfaces' do
      post :interfaces, params: { host: { organization_id: taxonomies(:organization1).id,
                                          location_id: taxonomies(:location1).id }},
           session: set_session_user, xhr: true
      assert_response :success

      options = Nokogiri::HTML(@response.body).css('select.interface_domain > option').map(&:text).uniq.reject(&:blank?)

      assert_includes options, domains(:mydomain).name
      assert_includes options, domains(:yourdomain).name
      refute_includes options, domains(:useless).name
    end
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
