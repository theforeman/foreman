require 'test_helper'
require 'controllers/shared/smart_proxies_controller_shared_test'

class Api::V2::SmartProxiesControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'master02', :url => 'http://server:8443' }
  include SmartProxiesControllerSharedTest

  setup do
    stub_smart_proxy_v2_features
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:smart_proxies)
    smart_proxies = ActiveSupport::JSON.decode(@response.body)
    refute_empty smart_proxies
  end

  test "should get index filtered by feature" do
    get :index, params: { :search => "feature=TFTP" }
    assert_response :success
    refute_empty assigns(:smart_proxies)
    smart_proxies = ActiveSupport::JSON.decode(@response.body)
    refute_empty smart_proxies

    returned_proxy_ids = smart_proxies['results'].map { |p| p["id"] }
    expected_proxy_ids = SmartProxy.unscoped.with_features("TFTP").map { |p| p.id }
    assert_equal expected_proxy_ids, returned_proxy_ids
  end

  test "should get index filtered by name" do
    get :index, params: { :search => "name ~ \"*TFTP*\"" }
    assert_response :success
    refute_empty assigns(:smart_proxies)
    smart_proxies = ActiveSupport::JSON.decode(@response.body)
    refute_empty smart_proxies

    returned_proxy_ids = smart_proxies['results'].map { |p| p["id"] }
    expected_proxy_ids = SmartProxy.unscoped.with_features("TFTP").map { |p| p.id }
    assert_equal expected_proxy_ids, returned_proxy_ids
  end
  test "should get index including status" do
    stub_smart_proxy_v2_features_and_statuses
    get :index, params: { :include_status => true }
    assert_response :success
    smart_proxies = ActiveSupport::JSON.decode(@response.body)
    returned_proxy_status = smart_proxies['results'].map { |p| p["status"] }
    number_of_proxies = smart_proxies['results'].map { |p| p["id"] }.count
    assert_equal number_of_proxies, returned_proxy_status.count
  end

  test "should show individual record" do
    get :show, params: { :id => smart_proxies(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute_empty show_response
  end

  test "should show individual record with including status" do
    stub_smart_proxy_v2_features_and_statuses
    get :show, params: { :id => smart_proxies(:one).to_param, :include_status => true }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_includes show_response, 'status'
    refute_includes show_response, 'version'
  end

  test "should show individual record including version" do
    stub_smart_proxy_v2_features_and_statuses
    get :show, params: { :id => smart_proxies(:one).to_param, :include_version => true }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute_includes show_response, 'status'
    assert_includes show_response, 'version'
  end

  test_attributes :pid => '0ffe0dc5-675e-45f4-b7e1-a14d3dd81f6e'
  test "should create smart_proxy" do
    assert_difference('SmartProxy.unscoped.count') do
      post :create, params: { :smart_proxy => valid_attrs }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert_equal valid_attrs[:name], response['name']
    assert response.key?('url')
    assert_equal valid_attrs[:url], response['url']
  end

  test_attributes :pid => 'f629cd9b-45ae-44ee-b724-9a768f958428'
  test "should not create smart_proxy with invalid name" do
    assert_difference('SmartProxy.unscoped.count', 0) do
      post :create, params: { :smart_proxy => valid_attrs.merge(:name => '') }
    end
    assert_response :unprocessable_entity
  end

  test_attributes :pid => '2c5e70e0-75ea-4521-a9ef-1d1cdc5bcbf7'
  test "should not create smart_proxy with invalid url" do
    assert_difference('SmartProxy.unscoped.count', 0) do
      post :create, params: { :smart_proxy => valid_attrs.merge(:url => '') }
    end
    assert_response :unprocessable_entity
    assert_match 'URL must be valid and schema must be one of http and https', @response.body
  end

  test "should update smart_proxy" do
    put :update, params: { :id => smart_proxies(:one).to_param, :smart_proxy => valid_attrs }
    assert_response :success
  end

  test_attributes :pid => 'fbde9f87-33db-4b95-a5f7-71a618460c84'
  test "should return any organization field when updating smart_proxy" do
    any_needed_fields = %w[organization organization_ids organizations]
    put :update, params: { :id => smart_proxies(:one).to_param, :smart_proxy => valid_attrs }
    assert_response :success
    response = JSON.parse(@response.body)
    refute_empty response.keys.select { |key| any_needed_fields.include?(key) }
  end

  test_attributes :pid => '42d6b749-c047-4fd2-90ee-ffab7be558f9'
  test "should return any location field when updating smart_proxy" do
    any_needed_fields = %w[location location_ids locations]
    put :update, params: { :id => smart_proxies(:one).to_param, :smart_proxy => valid_attrs }
    assert_response :success
    response = JSON.parse(@response.body)
    refute_empty response.keys.select { |key| any_needed_fields.include?(key) }
  end

  test_attributes :pid => 'f279640e-d7e9-48a3-aed8-7bf406e9d6f2'
  test "should update smart_proxy name only" do
    new_name = 'new_smart_proxy'
    put :update, params: { :id => smart_proxies(:one).to_param, :smart_proxy => { :name => new_name } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert_equal new_name, response['name']
  end

  test_attributes :pid => '0305fd54-4e0c-4dd9-a537-d342c3dc867e'
  test "should update smart_proxy url only" do
    new_url = 'https://new-valid_server_url.com:8443'
    put :update, params: { :id => smart_proxies(:one).to_param, :smart_proxy => { :url => new_url } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('url')
    assert_equal new_url, response['url']
  end

  test_attributes :pid => '62631275-7a92-4d34-a949-c56e0c4063f1'
  test "should update smart_proxy organizations" do
    organization_ids = [taxonomies(:organization2).id, taxonomies(:empty_organization).id].sort
    smart_proxy = smart_proxies(:one)
    put :update, params: { :id => smart_proxy.to_param, :smart_proxy => { :organization_ids => organization_ids } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('organizations')
    assert_equal organization_ids, response['organizations'].map { |org| org['id'] }.sort
  end

  test_attributes :pid => 'e08eaaa9-7c11-4cda-bbe7-6d1f7c732569'
  test "should update smart_proxy locations" do
    location_ids = [taxonomies(:location1).id, taxonomies(:location2).id].sort
    smart_proxy = smart_proxies(:one)
    put :update, params: { :id => smart_proxy.to_param, :smart_proxy => { :location_ids => location_ids } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('locations')
    assert_equal location_ids, response['locations'].map { |loc| loc['id'] }.sort
  end

  test_attributes :pid => '4afbeac4-ac8c-4e03-9845-81923dbb5b3d'
  test "should not update smart_proxy with invalid name" do
    put :update, params: { :id => smart_proxies(:one).to_param, :smart_proxy => { :name => '' } }
    assert_response :unprocessable_entity
    assert_match 'Name can\'t be blank', @response.body
  end

  test_attributes :pid => '86df219d-f354-4a9c-97ee-72bb7acb7f5b'
  test "should not update smart_proxy with invalid url" do
    put :update, params: { :id => smart_proxies(:one).to_param, :smart_proxy => { :url => '' } }
    assert_response :unprocessable_entity
    assert_match 'URL must be valid and schema must be one of http and https', @response.body
  end

  test_attributes :pid => '872bf12e-736d-43d1-87cf-2923966b59d0'
  test "should destroy smart_proxy" do
    smart_proxy = smart_proxies(:four)
    assert_difference('SmartProxy.unscoped.count', -1) do
      delete :destroy, params: { :id => smart_proxy.to_param }
    end
    assert_response :success
    refute SmartProxy.unscoped.exists?(smart_proxy.id)
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
    post :refresh, params: { :id => proxy }
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal Feature.all.pluck(:name).flatten.sort, response['features'].map { |x| x['name'] }.sort
  end

  test "should return errors during smart proxy refresh" do
    proxy = smart_proxies(:one)
    errors = ActiveModel::Errors.new(Host::Managed.new)
    errors.add :base, "Unable to communicate with the proxy: it's down"
    SmartProxy.any_instance.stubs(:errors).returns(errors)
    post :refresh, params: { :id => proxy }, session: set_session_user
    assert_response :unprocessable_entity
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
    assert_difference('Environment.unscoped.count', 2) do
      post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id }, session: set_session_user
    end
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal 2, response['environments_with_new_puppetclasses']
  end

  # this is intentional: put test_attributes only for the first generated test eg: dryrun_param = {}
  test_attributes :pid => '385efd1b-6146-47bf-babf-0127ce5955ed'
  [{}, { :dryrun => false }, { :dryrun => 'false' }].each do |dryrun_param|
    test "should import new puppetclasses" do
      setup_import_classes
      as_admin do
        Host::Managed.update_all(:environment_id => nil)
        Hostgroup.update_all(:environment_id => nil)
        Puppetclass.destroy_all
        Environment.destroy_all
        assert_difference('Puppetclass.unscoped.count', 1) do
          post :import_puppetclasses,
            params: { :id => smart_proxies(:puppetmaster).id }.merge(dryrun_param),
            session: set_session_user
        end
      end
      assert_response :success
      assert_match 'Successfully updated environment and puppetclasses from the on-disk puppet installation', @response.body
    end
  end

  test "should not import new puppetclasses when dryrun" do
    setup_import_classes
    as_admin do
      Host::Managed.update_all(:environment_id => nil)
      Hostgroup.update_all(:environment_id => nil)
      Puppetclass.destroy_all
      Environment.destroy_all
      assert_difference('Puppetclass.unscoped.count', 0) do
        post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id, :dryrun => true }, session: set_session_user
      end
    end
    assert_response :success
  end

  test "should obsolete environment" do
    setup_import_classes
    as_admin do
      Environment.create!(:name => 'xyz')
    end
    assert_difference('Environment.unscoped.count', -1) do
      post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id }, session: set_session_user
    end
    assert_response :success
  end

  test "should obsolete puppetclasses" do
    setup_import_classes
    as_admin do
      assert_difference('Environment.unscoped.find_by_name("env1").puppetclasses.count', -2) do
        post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id }, session: set_session_user
      end
    end
    assert_response :success
  end

  test "should update puppetclass smart class parameters" do
    setup_import_classes
    LookupKey.destroy_all
    assert_difference('LookupKey.unscoped.count', 1) do
      post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id }, session: set_session_user
    end
    assert_response :success
  end

  test "no changes on import_puppetclasses" do
    setup_import_classes
    Puppetclass.find_by_name('b').destroy
    Puppetclass.find_by_name('c').destroy
    assert_difference('Environment.unscoped.count', 0) do
      post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id }, session: set_session_user
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
      assert_difference('Environment.unscoped.count', 1) do
        post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id, :environment_id => env_name }, session: set_session_user
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
    assert_difference('Environment.unscoped.count', 0) do
      post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id, :except => 'obsolete' }, session: set_session_user
    end
    assert_response :success
  end

  test "should NOT add or update puppetclass smart class parameters if pass ?except=new,updated" do
    setup_import_classes
    LookupKey.destroy_all
    assert_difference('LookupKey.unscoped.count', 0) do
      post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id, :except => 'new,updated' }, session: set_session_user
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
        post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id }, session: set_session_user
        assert_template "api/v2/import_puppetclasses/index"
      end
    end

    test "should import puppetclasses for specified environment only" do
      assert_difference('Puppetclass.unscoped.count', 1) do
        post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id, :environment_id => 'env1' }, session: set_session_user
        assert_includes Puppetclass.pluck(:name), 'a'
        refute_includes Puppetclass.pluck(:name), 'b'
      end
      assert_response :success
    end

    test "should import puppetclasses for all environments if none specified" do
      assert_difference('Puppetclass.unscoped.count', 2) do
        post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id }, session: set_session_user
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
          post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id }, session: set_session_user
          assert_response :success
          response = ActiveSupport::JSON.decode(@response.body)
          assert_equal env_name, response['results'][0]['ignored_environment']
        end
      end

      test 'should contain ignored puppet_classes' do
        PuppetClassImporter.any_instance.stubs(:ignored_classes).returns([/^a$/])

        as_admin do
          post :import_puppetclasses, params: { :id => smart_proxies(:puppetmaster).id }, session: set_session_user
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
    get :version, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal('1.11', show_response['result']['version'])
  end

  test "smart proxy version failed" do
    ProxyStatus::Version.any_instance.stubs(:version).raises(Foreman::Exception, 'Exception message')
    get :version, params: { :id => smart_proxies(:one).to_param }, session: set_session_user
    assert_response :unprocessable_entity
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Exception message/, show_response['error']['message'])
  end

  test "smart proxy logs succeeded" do
    ProxyStatus::Logs.any_instance.stubs(:logs).returns({"info" => {"size" => 1000, "tail_size" => 500 }, "logs" => [] })
    get :logs, params: { :id => smart_proxies(:logs).to_param }, session: set_session_user
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal(1000, show_response['result']['info']['size'])
  end

  test "smart proxy logs failed" do
    ProxyStatus::Logs.any_instance.stubs(:logs).raises(Foreman::Exception, 'Exception message')
    get :logs, params: { :id => smart_proxies(:logs).to_param }, session: set_session_user
    assert_response :unprocessable_entity
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Exception message/, show_response['error']['message'])
  end
end
