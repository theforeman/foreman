require 'test_helper'

class Api::V1::SmartProxiesControllerTest < ActionController::TestCase
  include ForemanTasks::TestHelpers::WithInThreadExecutor
  valid_attrs = { :name => 'master02', :url => 'http://server:8443' }

  setup do
    ProxyAPI::Features.any_instance.stubs(:features => Feature.name_map.keys)
  end

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:smart_proxies)
    smart_proxies = ActiveSupport::JSON.decode(@response.body)
    assert_not smart_proxies.empty?
  end

  test "should get index filtered by type" do
    as_user :admin do
      get :index, { :type => 'TFTP' }
    end
    assert_response :success
    assert_not_nil assigns(:smart_proxies)
    smart_proxies = ActiveSupport::JSON.decode(@response.body)
    assert_not smart_proxies.empty?

    returned_proxy_ids = smart_proxies.map { |p| p["smart_proxy"]["id"] }
    expected_proxy_ids = SmartProxy.with_features("TFTP").map { |p| p.id }
    assert returned_proxy_ids == expected_proxy_ids
  end

  test "index should fail with invalid type filter" do
    as_user :admin do
      get :index, { :type => 'unknown_type' }
    end
    assert_response :error
  end

  test "should show individual record" do
    get :show, { :id => smart_proxies(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not show_response.empty?
  end

  test "should create smart_proxy" do
    assert_difference('SmartProxy.count') do
      post :create, { :smart_proxy => valid_attrs }
    end
    assert_response :success
  end

  test "should update smart_proxy" do
    put :update, { :id => smart_proxies(:one).to_param, :smart_proxy => valid_attrs }
    assert_response :success
  end

  test "should destroy smart_proxy" do
    assert_difference('SmartProxy.count', -1) do
      delete :destroy, { :id => smart_proxies(:four).to_param }
    end
    assert_response :success
  end

  # Pending - failure on .permission_failed?
  # test "should not destroy smart_proxy that is in use" do
  #   as_user :admin do
  #     assert_difference('SmartProxy.count', 0) do
  #       delete :destroy, {:id => smart_proxies(:one).to_param}
  #     end
  #   end
  #   assert_response :unprocessable_entity
  # end

  test "should refresh smart proxy features" do
    proxy = smart_proxies(:one)
    SmartProxy.any_instance.stubs(:associate_features).returns(true)
    post :refresh, {:id => proxy}
    assert_response :success
  end

  test "should return errors during smart proxy refresh" do
    proxy = smart_proxies(:one)
    errors = ActiveModel::Errors.new(Host::Managed.new)
    errors.add :base, "Unable to communicate with the proxy: it's down"
    SmartProxy.any_instance.stubs(:errors).returns(errors)
    SmartProxy.any_instance.stubs(:associate_features).returns(true)
    post :refresh, {:id => proxy}, set_session_user
    assert_response :unprocessable_entity
  end

  # same method as in EnvironmentsControllerTest
  def setup_import_classes
    as_admin do
      Host::Managed.update_all(:environment_id => nil)
      Hostgroup.update_all(:environment_id => nil)
      HostClass.destroy_all
      HostgroupClass.destroy_all
      Puppetclass.destroy_all
      Environment.destroy_all
    end
    # This is the database status
    # and should result in a db_tree of {"env1" => ["a", "b", "c"], "env2" => ["a", "b", "c"]}
    as_admin do
      ["a", "b", "c"].each {|name| Puppetclass.create :name => name}
      for name in ["env1", "env2"] do
        e = Environment.create!(:name => name)
        e.puppetclasses = Puppetclass.all
      end
    end
    # This is the on-disk status
    # and should result in a disk_tree of {"env1" => ["a", "b", "c"],"env2" => ["a", "b", "c"]}
    envs = HashWithIndifferentAccess.new(:env1 => %w{a b c}, :env2 => %w{a b c})
    pcs = [HashWithIndifferentAccess.new("a" => { "name" => "a", "module" => nil, "params"=> {'key' => 'special'} })]
    classes = Hash[pcs.map { |k| [k.keys.first, Foreman::ImporterPuppetclass.new(k.values.first)] }]
    Environment.expects(:puppetEnvs).returns(envs).at_least(0)
    ProxyAPI::Puppet.any_instance.stubs(:environments).returns(["env1", "env2"])
    ProxyAPI::Puppet.any_instance.stubs(:classes).returns(classes)
  end

  # puppetmaster proxy - import_puppetclasses tests

  test "should import new environments" do
    setup_import_classes
    as_admin do
      Host::Managed.update_all(:environment_id => nil)
      Hostgroup.update_all(:environment_id => nil)
      Puppetclass.destroy_all
      Environment.destroy_all
    end
    assert_difference('Environment.count', 2) do
      post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id}, set_session_user
    end
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal 2, response['environments_with_new_puppetclasses']
  end

  [{}, { :dryrun => false }, { :dryrun => 'false' }].each do |dryrun_param|
    test "should import new puppetclasses" do
      setup_import_classes
      as_admin do
        Host::Managed.update_all(:environment_id => nil)
        Hostgroup.update_all(:environment_id => nil)
        Puppetclass.destroy_all
        Environment.destroy_all
        assert_difference('Puppetclass.count', 1) do
          post :import_puppetclasses,
               { :id => smart_proxies(:puppetmaster).id }.merge(dryrun_param),
               set_session_user
        end
      end
      assert_response :success
    end
  end

  test "should not import new puppetclasses when dryrun" do
    setup_import_classes
    as_admin do
      Host::Managed.update_all(:environment_id => nil)
      Hostgroup.update_all(:environment_id => nil)
      Puppetclass.destroy_all
      Environment.destroy_all
      assert_difference('Puppetclass.count', 0) do
        post :import_puppetclasses, { :id => smart_proxies(:puppetmaster).id, :dryrun => true }, set_session_user
      end
    end
    assert_response :success
  end

  test "should obsolete environment" do
    setup_import_classes
    as_admin do
      Environment.create!(:name => 'xyz')
    end
    assert_difference('Environment.count', -1) do
      post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id}, set_session_user
    end
    assert_response :success
  end

  test "should obsolete puppetclasses" do
    setup_import_classes
    as_admin do
      assert_difference('Environment.find_by_name("env1").puppetclasses.count', -2) do
        post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id}, set_session_user
      end
    end
    assert_response :success
  end

  test "should update puppetclass smart class parameters" do
    setup_import_classes
    LookupKey.destroy_all
    assert_difference('LookupKey.count', 1) do
      post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id}, set_session_user
    end
    assert_response :success
  end

  test "no changes on import_puppetclasses" do
    setup_import_classes
    Puppetclass.find_by_name('b').destroy
    Puppetclass.find_by_name('c').destroy
    assert_difference('Environment.count', 0) do
      post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id}, set_session_user
    end
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal 'Successfully updated environment and puppetclasses from the on-disk puppet installation', response['message']
  end

  test "should import new environment that does not exist in db" do
    setup_import_classes
    as_admin do
      env_name = 'env1'
      assert Environment.find_by_name(env_name).destroy
      assert_difference('Environment.count', 1) do
        post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id, :environment_id => env_name}, set_session_user
      end
      assert_response :success
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal env_name, response['results']['name']
    end
  end
end
