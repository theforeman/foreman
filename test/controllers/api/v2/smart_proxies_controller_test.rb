require 'test_helper'

class Api::V2::SmartProxiesControllerTest < ActionController::TestCase
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
    assert !smart_proxies.empty?
  end

  test "should get index filtered by feature" do
    get :index, { :search => "feature=TFTP" }
    assert_response :success
    refute_empty assigns(:smart_proxies)
    smart_proxies = ActiveSupport::JSON.decode(@response.body)
    refute_empty smart_proxies

    returned_proxy_ids = smart_proxies['results'].map { |p| p["id"] }
    expected_proxy_ids = SmartProxy.with_features("TFTP").map { |p| p.id }
    assert_equal expected_proxy_ids, returned_proxy_ids
  end

  test "should get index filtered by name" do
    get :index, { :search => "name ~ \"*TFTP*\"" }
    assert_response :success
    refute_empty assigns(:smart_proxies)
    smart_proxies = ActiveSupport::JSON.decode(@response.body)
    refute_empty smart_proxies

    returned_proxy_ids = smart_proxies['results'].map { |p| p["id"] }
    expected_proxy_ids = SmartProxy.with_features("TFTP").map { |p| p.id }
    assert_equal expected_proxy_ids, returned_proxy_ids
  end

  test "should show individual record" do
    get :show, { :id => smart_proxies(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create smart_proxy" do
    assert_difference('SmartProxy.count') do
      post :create, { :smart_proxy => valid_attrs }
    end
    assert_response :created
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

  test "should NOT delete environment if pass ?except=obsolete" do
    setup_import_classes
    as_admin do
      Environment.create!(:name => 'xyz')
    end
    assert_difference('Environment.count', 0) do
      post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id, :except => 'obsolete'}, set_session_user
    end
    assert_response :success
  end

  test "should NOT add or update puppetclass smart class parameters if pass ?except=new,updated" do
    setup_import_classes
    LookupKey.destroy_all
    assert_difference('LookupKey.count', 0) do
     post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id, :except => 'new,updated'}, set_session_user
    end
    assert_response :success
  end

  context 'import puppetclasses' do
    setup do
      ProxyAPI::Puppet.any_instance.stubs(:environments).returns(["env1", "env2"])
      classes_env1 = {'a' => Foreman::ImporterPuppetclass.new('name' => 'a')}
      classes_env2 = {'b' => Foreman::ImporterPuppetclass.new('name' => 'b')}
      ProxyAPI::Puppet.any_instance.stubs(:classes).returns(classes_env1.merge(classes_env2))
      ProxyAPI::Puppet.any_instance.stubs(:classes).with('env1').returns(classes_env1)
      ProxyAPI::Puppet.any_instance.stubs(:classes).with('env2').returns(classes_env2)
    end

    test 'should render templates according to api version 2' do
      as_admin do
        post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id}, set_session_user
        assert_template "api/v2/import_puppetclasses/index"
      end
    end

    test "should import puppetclasses for specified environment only" do
      assert_difference('Puppetclass.count', 1) do
        post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id, :environment_id => 'env1'}, set_session_user
        assert_includes Puppetclass.pluck(:name), 'a'
        refute_includes Puppetclass.pluck(:name), 'b'
      end
      assert_response :success
    end

    test "should import puppetclasses for all environments if none specified" do
      assert_difference('Puppetclass.count', 2) do
        post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id}, set_session_user
        assert_includes Puppetclass.pluck(:name), 'a'
        assert_includes Puppetclass.pluck(:name), 'b'
      end
      assert_response :success
    end

    context 'ignored entvironments or classes are set' do
      setup do
        setup_import_classes
      end

      test 'should contain ignored environments' do
        env_name = 'env1'
        PuppetClassImporter.any_instance.stubs(:ignored_environments).returns([env_name])

        as_admin do
          post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id}, set_session_user
          assert_response :success
          response = ActiveSupport::JSON.decode(@response.body)
          assert_equal env_name, response['results'][0]['ignored_environment']
        end
      end

      test 'should contain ignored puppet_classes' do
        PuppetClassImporter.any_instance.stubs(:ignored_classes).returns([/^a$/])

        as_admin do
          post :import_puppetclasses, {:id => smart_proxies(:puppetmaster).id}, set_session_user
          assert_response :success
          response = ActiveSupport::JSON.decode(@response.body)
          assert_includes response['results'][0]['ignored_puppetclasses'], 'a'
          refute_includes response['results'][0]['ignored_puppetclasses'], 'c'
        end
      end
    end
  end

  test "smart proxy version succeeded" do
    ProxyStatus::Version.any_instance.stubs(:version).returns({"version" => "1.11", "modules" => {}})
    get :version, { :id => smart_proxies(:one).to_param }, set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal('1.11', show_response['result']['version'])
  end

  test "smart proxy version failed" do
    ProxyStatus::Version.any_instance.stubs(:version).raises(Foreman::Exception, 'Exception message')
    get :version, { :id => smart_proxies(:one).to_param }, set_session_user
    assert_response :unprocessable_entity
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Exception message/, show_response['error']['message'])
  end

  test "smart proxy logs succeeded" do
    ProxyStatus::Logs.any_instance.stubs(:logs).returns({"info" => {"size" => 1000, "tail_size" => 500 }, "logs" => [] })
    get :logs, { :id => smart_proxies(:logs).to_param }, set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal(1000, show_response['result']['info']['size'])
  end

  test "smart proxy logs failed" do
    ProxyStatus::Logs.any_instance.stubs(:logs).raises(Foreman::Exception, 'Exception message')
    get :logs, { :id => smart_proxies(:logs).to_param }, set_session_user
    assert_response :unprocessable_entity
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Exception message/, show_response['error']['message'])
  end
end
