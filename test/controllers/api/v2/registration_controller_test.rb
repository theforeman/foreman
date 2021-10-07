require 'test_helper'

class Api::V2::RegistrationControllerTest < ActionController::TestCase
  describe 'global registration' do
    test "should get template" do
      get :global
      assert_response :success
      assert_equal @response.body, templates(:global_registration).template
    end

    test "should render not_found" do
      Setting[:default_global_registration_item] = ""
      get :global
      assert_response :not_found
    end

    test "should render error when template is invalid" do
      Foreman::Renderer::Source::Database.any_instance.stubs(:content).returns("<% asda =!?== '2 % %>")
      get :global
      assert_response :internal_server_error
    end

    test "should pass permitted params to template" do
      params = {
        organization_id: taxonomies(:organization1).id,
        location_id: taxonomies(:location1).id,
        hostgroup_id: hostgroups(:common).id,
        operatingsystem_id: operatingsystems(:centos5_3).id,
      }

      get :global, params: params, session: set_session_user
      assert_response :success

      vars = assigns(:global_registration_vars)
      assert_equal taxonomies(:organization1), vars[:organization]
      assert_equal taxonomies(:location1), vars[:location]
      assert_equal hostgroups(:common), vars[:hostgroup]
      assert_equal operatingsystems(:centos5_3), vars[:operatingsystem]
      assert_equal users(:admin), vars[:user]
      assert_equal register_url, vars[:registration_url].to_s
    end

    test "should not pass unpermitted params to template" do
      params = {
        not_allowed: 'something_not_allowed',
      }

      get :global, params: params, session: set_session_user
      assert_response :success
      assert_nil assigns(:global_registration_vars)[:not_allowed]
    end

    test "should allow to extend permitted params" do
      Foreman::Plugin.any_instance.stubs(:allowed_registration_vars).returns([:activation_key])
      get :global, params: { activation_key: 'one-two-three-key' }, session: set_session_user
      assert_response :success
      assert_equal 'one-two-three-key', assigns(:global_registration_vars)[:activation_key]
    end

    test 'should fail when resources are not found' do
      get :global, params: { organization_id: 0 }, session: set_session_user
      assert_response :not_found
      assert_includes @response.body, "echo \"Organization with id 0 not found\";"

      get :global, params: { location_id: 0 }, session: set_session_user
      assert_response :not_found
      assert_includes @response.body, "echo \"Location with id 0 not found\";"

      get :global, params: { hostgroup_id: 0 }, session: set_session_user
      assert_response :not_found
      assert_includes @response.body, "echo \"Couldn't find Hostgroup with 'id'=0\""
    end

    context 'with :url parameter' do
      after do
        ENV['RAILS_RELATIVE_URL_ROOT'] = nil
      end

      test 'without protocol and without port' do
        get :global, params: { url: 'example.com' }, session: set_session_user
        assert_response :internal_server_error
      end

      test 'without protocol and with port' do
        get :global, params: { url: 'example.com:0' }, session: set_session_user
        assert_response :internal_server_error
      end

      test 'with http protocol' do
        url = 'http://example.com'
        get :global, params: { url: url }, session: set_session_user
        assert_response :success
        assert_equal "#{url}/register", assigns(:global_registration_vars)[:registration_url].to_s
      end

      test 'with https protocol' do
        url = 'https://example.com'
        get :global, params: { url: url }, session: set_session_user
        assert_response :success
        assert_equal "#{url}/register", assigns(:global_registration_vars)[:registration_url].to_s
      end

      test 'with port' do
        url = 'https://example.com:0'
        get :global, params: { url: url }, session: set_session_user
        assert_response :success
        assert_equal "#{url}/register", assigns(:global_registration_vars)[:registration_url].to_s
      end

      test 'with path' do
        url = 'https://example.com/this-path-should-not-be-here'
        get :global, params: { url: url }, session: set_session_user
        assert_response :success
        assert_equal 'https://example.com/register', assigns(:global_registration_vars)[:registration_url].to_s
      end

      test 'with RAILS_RELATIVE_URL_ROOT' do
        ENV['RAILS_RELATIVE_URL_ROOT'] = '/foreman'
        url = 'https://example.com'
        get :global, params: { url: url }, session: set_session_user
        assert_response :success
        assert_equal "#{url}/register", assigns(:global_registration_vars)[:registration_url].to_s
      end
    end
  end

  describe 'host registration' do
    let(:host_params) { { host: { name: 'centos-test.example.com', operatingsystem_id: operatingsystems(:redhat).id } } }

    test 'should find and create host' do
      post :host, params: host_params, session: set_session_user
      assert_response :success
      assert_not_nil Host.find_by(name: host_params[:host][:name])
    end

    test 'should find and update host' do
      params = { host: { name: host_params[:host][:name], hostgroup_id: hostgroups(:common).id } }

      Host.create(host_params[:host])

      post :host, params: params, session: set_session_user
      assert_response :success
      assert_equal Host.find_by(name: params[:host][:name]).hostgroup_id, params[:host][:hostgroup_id]
    end

    test 'should render template' do
      post :host, params: host_params, session: set_session_user
      assert_response :success
      assert_equal @response.body, "echo \"Linux host initial configuration\""
    end

    test 'should set build on host' do
      post :host, params: host_params, session: set_session_user
      assert_response :success
      assert Host.find_by(name: host_params[:host][:name]).build
    end

    test 'should render error when no OS' do
      host_params = { host: { name: 'centos-test.example.com', managed: false, build: false } }
      post :host, params: host_params, session: set_session_user
      assert_response :unprocessable_entity
      assert_includes @response.body, '[Foreman::Exception]: Must provide an operating system'
    end

    test 'should render error when template is invalid' do
      template = FactoryBot.create(
        :provisioning_template,
        template_kind: template_kinds(:host_init_config),
        template: "<% asda =!?== '2 % %>"
      )

      Setting[:default_host_init_config_template] = template.name
      host_params = { host: { name: 'centos-test.example.com', operatingsystem_id: FactoryBot.create(:operatingsystem).id } }

      post :host, params: host_params, session: set_session_user
      assert_response :internal_server_error
    end

    test 'with unsupported media_type' do
      post :host, params: host_params, session: set_session_user, as: :html
      assert_response :unsupported_media_type
    end

    context 'setup_insights' do
      test 'without param' do
        params = { setup_insights: '' }.merge(host_params)
        post :host, params: params, session: set_session_user
        assert_response :success

        host = Host.find_by(name: params[:host][:name]).reload
        assert_nil HostParameter.find_by(host: host, name: 'host_registration_insights')
      end

      test 'with setup_insights = true' do
        params = { setup_insights: 'true' }.merge(host_params)
        post :host, params: params, session: set_session_user
        assert_response :success

        host = Host.find_by(name: params[:host][:name]).reload
        assert HostParameter.find_by(host: host, name: 'host_registration_insights').value
      end

      test 'with setup_insights = false' do
        params = { setup_insights: 'false' }.merge(host_params)

        post :host, params: params, session: set_session_user
        assert_response :success

        host = Host.find_by(name: params[:host][:name]).reload
        refute HostParameter.find_by(host: host, name: 'host_registration_insights').value
      end
    end

    context 'setup_remote_execution' do
      test 'without param' do
        params = { setup_remote_execution: '' }.merge(host_params)
        post :host, params: params, session: set_session_user
        assert_response :success

        host = Host.find_by(name: params[:host][:name]).reload
        assert_nil HostParameter.find_by(host: host, name: 'host_registration_remote_execution')
      end

      test 'with setup_remote_execution = true' do
        params = { setup_remote_execution: 'true' }.merge(host_params)
        post :host, params: params, session: set_session_user
        assert_response :success

        host = Host.find_by(name: params[:host][:name]).reload
        assert HostParameter.find_by(host: host, name: 'host_registration_remote_execution').value
      end

      test 'with setup_remote_execution = false' do
        params = { setup_remote_execution: 'false' }.merge(host_params)

        post :host, params: params, session: set_session_user
        assert_response :success

        host = Host.find_by(name: params[:host][:name]).reload
        refute HostParameter.find_by(host: host, name: 'host_registration_remote_execution').value
      end
    end

    context 'packages' do
      test 'without param' do
        params = { packages: '' }.merge(host_params)
        post :host, params: params, session: set_session_user
        assert_response :success

        host = Host.find_by(name: params[:host][:name]).reload
        assert_nil HostParameter.find_by(host: host, name: 'host_packages')
      end

      test 'with param' do
        params = { packages: 'pkg1 pkg2' }.merge(host_params)
        post :host, params: params, session: set_session_user
        assert_response :success

        host = Host.find_by(name: params[:host][:name]).reload
        assert HostParameter.find_by(host: host, name: 'host_packages').value
      end
    end

    context 'prepare host' do
      test 'Apply inherited attributes from host group' do
        params = { host: { name: 'hostgroup.example.com', hostgroup_id: hostgroups(:common).id }}

        post :host, params: params, session: set_session_user
        assert_response :success

        host = Host.find_by(name: params[:host][:name]).reload
        assert hostgroups(:common).operatingsystem_id, host.operatingsystem_id
      end
    end
  end
end
