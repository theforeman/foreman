require 'test_helper'
require 'controllers/shared/pxe_loader_test'

class Api::V2::HostgroupsControllerTest < ActionController::TestCase
  include ::PxeLoaderTest

  def basic_attrs
    {
      :architecture_id     => Architecture.find_by_name('x86_64').id,
      :operatingsystem_id  => Operatingsystem.find_by_name('Redhat').id,
    }
  end

  def valid_attrs
    { :name => 'TestHostgroup' }
  end

  def valid_attrs_with_root(extra_attrs = {})
    { :hostgroup => valid_attrs.merge(extra_attrs) }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:hostgroups)
    hostgroups = ActiveSupport::JSON.decode(@response.body)
    assert !hostgroups.empty?
    assert hostgroups['results'].select { |h| h.has_key?('parameters') }.empty?
  end

  test "should get index with parameters" do
    get :index, params: { :include => ['parameters'] }
    assert_response :success
    hostgroups = ActiveSupport::JSON.decode(@response.body)
    assert !hostgroups['results'].select { |h| h.has_key?('parameters') }.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => hostgroups(:common).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    assert show_response.has_key?('parameters')
  end

  test "should show inherited parameters" do
    get :show, params: { :id => hostgroups(:inherited).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal environments(:production).id, show_response['environment_id']
    assert_nil show_response['inherited_environment_id']
    assert_nil show_response['ptable_id']
    assert_equal templates(:autopart).id, show_response['inherited_ptable_id']
  end

  test "should show all puppet clases for individual record" do
    hostgroup = FactoryBot.create(:hostgroup, :with_config_group)
    get :show, params: { :id => hostgroup.id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    assert_not_equal 0, show_response['all_puppetclasses'].length
  end

  test_attributes :pid => 'fd5d353c-fd0c-4752-8a83-8f399b4c3416'
  test "should create hostgroup" do
    assert_difference('Hostgroup.unscoped.count') do
      post :create, params: { :hostgroup => valid_attrs }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert_equal response['name'], valid_attrs[:name]
  end

  test_attributes :pid => '5c715ee8-2fd6-42c6-aece-037733f67454'
  test "should create hostgroup with puppet_ca_proxy" do
    smart_proxy = smart_proxies(:puppetmaster)
    assert_difference('Hostgroup.unscoped.count') do
      post :create, params: { :hostgroup => valid_attrs.merge(:puppet_ca_proxy_id => smart_proxy.id) }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('puppet_ca_proxy_id')
    assert_equal smart_proxy.id, response['puppet_ca_proxy_id']
  end

  test_attributes :pid => '4f39f246-d12f-468c-a33b-66486c3806fe'
  test "should create hostgroup with puppet_proxy" do
    smart_proxy = smart_proxies(:puppetmaster)
    assert_difference('Hostgroup.unscoped.count') do
      post :create, params: { :hostgroup => valid_attrs.merge(:puppet_proxy_id => smart_proxy.id) }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('puppet_proxy_id')
    assert_equal smart_proxy.id, response['puppet_proxy_id']
  end

  test_attributes :pid => '8abb151f-a058-4f47-a1c1-f60a32cd7572'
  test "should update hostgroup" do
    # BZ: 1378009
    put :update, params: { :id => hostgroups(:common).to_param, :hostgroup => valid_attrs }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert_equal response['name'], valid_attrs[:name]
  end

  test_attributes :pid => 'fd13ab0e-1a5b-48a0-a852-3fff8306271f'
  test "should update puppet_ca_proxy" do
    host_group = hostgroups(:common)
    puppet_ca_proxy = smart_proxies(:puppetmaster)
    put :update, params: { :id => host_group.id, :hostgroup => { :puppet_ca_proxy_id => puppet_ca_proxy.id } }
    assert_response :success
    host_group.reload
    assert_equal puppet_ca_proxy.id, host_group.puppet_ca_proxy_id
  end

  test_attributes :pid => '86eca603-2cdd-4563-b6f6-aaa5cea1a723'
  test "should update puppet_proxy" do
    host_group = FactoryBot.create(:hostgroup)
    assert host_group.puppet_proxy_id.nil?
    puppet_proxy = smart_proxies(:puppetmaster)
    put :update, params: { :id => host_group.id, :hostgroup => { :puppet_proxy_id => puppet_proxy.id } }
    assert_response :success
    host_group.reload
    assert_equal puppet_proxy.id, host_group.puppet_proxy_id
  end

  test_attributes :pid => 'ab151e09-8e64-4377-95e8-584629750659'
  test "should read puppet_ca_proxy_name" do
    host_group = hostgroups(:common)
    puppet_ca_proxy = smart_proxies(:puppetmaster)
    host_group.puppet_ca_proxy_id = puppet_ca_proxy.id
    assert host_group.save
    get :show, params: { :id => host_group.id }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('puppet_ca_proxy_name')
    assert_equal puppet_ca_proxy.name, response['puppet_ca_proxy_name']
  end

  test_attributes :pid => 'f93d0866-0073-4577-8777-6d645b63264f'
  test "should read puppet_proxy_name" do
    host_group = hostgroups(:common)
    puppet_ca_proxy = smart_proxies(:puppetmaster)
    get :show, params: { :id => host_group.id }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('puppet_proxy_name')
    assert_equal puppet_ca_proxy.name, response['puppet_proxy_name']
  end

  test_attributes :pid => 'bef6841b-5077-4b84-842e-a286bfbb92d2'
  test "should destroy hostgroups" do
    assert_difference('Hostgroup.unscoped.count', -1) do
      delete :destroy, params: { :id => hostgroups(:unusual).to_param }
    end
    assert_response :success
  end

  test_attributes :pid => '44ac8b3b-9cb0-4a9e-ad9b-2c67b2411922'
  test "should clone hostgroup" do
    hostgroup = hostgroups(:common)
    assert_difference('Hostgroup.unscoped.count') do
      post :clone, params: { :id => hostgroup.id, :name => RFauxFactory.gen_alpha }
    end
    assert_response :success
    response = JSON.parse(@response.body)
    unique_attr_names = %w[updated_at created_at title id name lookup_value_matcher grub_pass]
    attr_names = response.keys.reject { |key| unique_attr_names.include?(key) || hostgroup[key].nil? }.sort
    refute attr_names.empty?
    cloned_values = attr_names.map { |key| response[key] }
    original_values = attr_names.map { |key| hostgroup[key] }
    assert_equal original_values, cloned_values
  end

  test_attributes :pid => '3f5aa17a-8db9-4fe9-b309-b8ec5e739da1'
  test "should not create hostgroup with invalid name" do
    assert_difference('Hostgroup.unscoped.count', 0) do
      post :create, params: { :hostgroup => { :name => '' } }
    end
    assert_response :unprocessable_entity
    assert_include @response.body, "Name can't be blank"
  end

  test_attributes :pid => '6d8c4738-a0c4-472b-9a71-27c8a3832335'
  test "should not update hostgroup with invalid name" do
    hostgroup = hostgroups(:common)
    put :update, params: { :id => hostgroup.id, :hostgroup => { :name => '' } }
    assert_response :unprocessable_entity
    assert_include @response.body, "Name can't be blank"
  end

  test "blocks API deletion of hosts with children" do
    assert hostgroups(:parent).has_children?
    assert_no_difference('Hostgroup.unscoped.count') do
      delete :destroy, params: { :id => hostgroups(:parent).to_param }
    end
    assert_response :conflict
  end

  test "should create nested hostgroup with a parent" do
    assert_difference('Hostgroup.unscoped.count') do
      post :create, params: { :hostgroup => valid_attrs.merge(:parent_id => hostgroups(:common).id) }
    end
    assert_response :success
    assert_equal hostgroups(:common).id.to_s, last_record.ancestry
  end

  test "should update a hostgroup to nested by passing parent_id" do
    put :update, params: { :id => hostgroups(:db).to_param, :hostgroup => {:parent_id => hostgroups(:common).id} }
    assert_response :success
    assert_equal hostgroups(:common).id.to_s,
      Hostgroup.unscoped.find_by_name("db").ancestry
  end

  test "user without view_params permission can't see hostgroup parameters" do
    hostgroup_with_parameter = FactoryBot.create(:hostgroup, :with_parameter)
    setup_user "view", "hostgroups"
    get :show, params: { :id => hostgroup_with_parameter.to_param, :format => 'json' }
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see hostgroup parameters" do
    hostgroup_with_parameter = FactoryBot.create(:hostgroup, :with_parameter)
    setup_user "view", "hostgroups"
    setup_user "view", "params"
    get :show, params: { :id => hostgroup_with_parameter.to_param, :format => 'json' }
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  context 'parameters type' do
    test "should create a group parameter with parameter type" do
      hostgroup_params = [{:name => "foo", :value => 42, :parameter_type => 'integer'}]
      post :create, params: { hostgroup: valid_attrs.merge(parameters: hostgroup_params) }
      assert_response :success
    end

    test "should show a group parameter with parameter type" do
      hostgroup = FactoryBot.create(:hostgroup)
      hostgroup.group_parameters.create!(:name => "foo", :value => 42, :parameter_type => 'integer')
      get :show, params: { :id => hostgroup.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 42, show_response['parameters'].first['value'].to_i
      assert_equal 'integer', show_response['parameters'].first['parameter_type']
    end

    test "should create a group parameter with default parameter type" do
      hostgroup_params = [{ :name => "foo", :value => 42 }]
      post :create, params: { hostgroup: valid_attrs.merge(parameters: hostgroup_params) }
      assert_response :success
    end

    test "should show a group parameter with default parameter type" do
      hostgroup = FactoryBot.create(:hostgroup)
      hostgroup.group_parameters.create!(:name => "foo", :value => 42)
      get :show, params: { :id => hostgroup.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 42, show_response['parameters'].first['value']
      assert_equal 'string', show_response['parameters'].first['parameter_type']
    end
  end

  context 'hidden parameters' do
    test "should create a group parameter with hidden_value" do
      hostgroup_params = [{:name => "foo", :value => "bar", :hidden_value => true}]
      post :create, params: { hostgroup: valid_attrs.merge(parameters: hostgroup_params) }
      assert_response :success
    end

    test "should show a group parameter as hidden unless show_hidden_parameters is true" do
      hostgroup = FactoryBot.create(:hostgroup)
      hostgroup.group_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => hostgroup.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal '*****', show_response['parameters'].first['value']
    end

    test "should show a group parameter as unhidden when show_hidden_parameters is true" do
      hostgroup = FactoryBot.create(:hostgroup)
      hostgroup.group_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => hostgroup.id, :show_hidden_parameters => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 'bar', show_response['parameters'].first['value']
    end
  end

  test "should update existing hostgroup parameters" do
    hostgroup = FactoryBot.create(:hostgroup)
    param_params = { :name => "foo", :value => "bar" }
    hostgroup.group_parameters.create!(param_params)
    put :update, params: { :id => hostgroup.id, :hostgroup => { :group_parameters_attributes => [{ :name => param_params[:name], :value => "new_value" }] } }
    assert_response :success
    assert param_params[:name], hostgroup.parameters[param_params[:name]]
  end

  test "should delete existing hostgroup parameters" do
    hostgroup = FactoryBot.create(:hostgroup)
    param_1 = { :name => "foo", :value => "bar" }
    param_2 = { :name => "boo", :value => "test" }
    hostgroup.group_parameters.create!([param_1, param_2])
    put :update, params: { :id => hostgroup.id, :hostgroup => { :group_parameters_attributes => [{ :name => param_1[:name], :value => "new_value" }] } }
    assert_response :success
    assert_equal 1, hostgroup.reload.parameters.keys.count
  end

  test "should successfully recreate host configs" do
    Hostgroup.any_instance.expects(:recreate_hosts_config).returns({'foo.example.com' => { "TFTP" => true, "DNS" => true, "DHCP" => true }})
    hostgroup = FactoryBot.create(:hostgroup)
    post :rebuild_config, params: { :id => hostgroup.to_param }, session: set_session_user
    assert_response :success
  end

  test "should not successfully recreate host configs" do
    Hostgroup.any_instance.expects(:recreate_hosts_config).returns({'foo.example.com' => { "TFTP" => true, "DNS" => false, "DHCP" => true }})
    hostgroup = FactoryBot.create(:hostgroup)
    post :rebuild_config, params: { :id => hostgroup.to_param }, session: set_session_user
    assert_response 422
  end

  test "should successfully recreate TFTP configs" do
    Hostgroup.any_instance.expects(:recreate_hosts_config).returns({'foo.example.com' => { "TFTP" => true}})
    hostgroup = FactoryBot.create(:hostgroup)
    post :rebuild_config, params: { :id => hostgroup.to_param, :only => ['TFTP'] }, session: set_session_user
    assert_response :success
  end

  describe 'facets works in API' do
    let(:hostgroup) { FactoryBot.create(:hostgroup) }
    let(:facet) { mock('HostgroupTestFacet') }

    setup do
      hostgroup # create prior facet stubing
      Api::V2::BaseController.append_view_path(Rails.root.join('test', 'static_fixtures', 'views'))
      facet_definition = mock('Facets::HostBaseEntry')
      facet_definition.stubs(name: :test_facet, api_single_view: 'api/v2/test/two', api_list_view: 'api/v2/test/facet')
      Hostgroup.any_instance.stubs(:facet_definitions).returns([facet_definition])

      facet_definition.stubs(:facet_record_for).returns(facet)
      facet.stubs(attributes: { 'id' => 123 })
    end

    test 'show include both views' do
      facet.expects(:foo).returns('bar')
      get :show, params: { id: hostgroup.to_param }
      json_response = JSON.parse(@response.body)
      assert_includes json_response.keys, 'two'
      assert_includes json_response.keys, 'facet_param'
      assert_equal json_response['facet_param'], 'bar'
    end

    test 'index include list view' do
      facet.expects(:foo).times(Hostgroup.count).returns('bar')
      get :index
      json_response = JSON.parse(@response.body)['results'].detect { |hostgroup_node| hostgroup_node['id'] == hostgroup.id }
      assert_not_includes json_response.keys, 'two'
      assert_includes json_response.keys, 'facet_param'
      assert_equal json_response['facet_param'], 'bar'
    end
  end

  private

  def last_record
    Hostgroup.unscoped.order(:id).last
  end
end
