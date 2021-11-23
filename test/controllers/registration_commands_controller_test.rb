require 'test_helper'

class RegistrationCommandsControllerTest < ActionController::TestCase
  describe 'operatingsystem_template' do
    test 'with template' do
      os = operatingsystems(:redhat)

      get :operatingsystem_template, params: { id: os.id }, session: set_session_user
      assert_response :success

      response = JSON.parse(@response.body)['template']
      template_name = Setting[:default_host_init_config_template]

      assert_includes response['path'], Template.find_by(name: template_name).id.to_s
      assert response['name'], template_name
    end

    test 'without template' do
      os = FactoryBot.create(:operatingsystem)
      os.os_default_templates = []

      get :operatingsystem_template, params: { id: os.id }, session: set_session_user

      response = JSON.parse(@response.body)['template']

      assert_response :success
      assert_includes response['os_path'], os.id.to_s
      assert_nil response['name']
    end
  end

  describe 'create' do
    test 'with params' do
      params = {
        organizationId: taxonomies(:organization1).id,
        locationId: taxonomies(:location1).id,
        hostgroupId: hostgroups(:common).id,
        operatingsystemId: operatingsystems(:redhat).id,
        update_packages: true,
      }
      post :create, params: params, session: set_session_user
      command = JSON.parse(@response.body)['command']

      assert_includes command, 'organizationId='
      assert_includes command, 'locationId='
      assert_includes command, 'hostgroupId='
      assert_includes command, 'operatingsystemId='
      assert_includes command, 'update_packages=true'
    end

    test 'with params ignored in URL' do
      features = [FactoryBot.create(:feature, name: 'Registration'), FactoryBot.create(:feature, name: 'Templates')]
      proxy = FactoryBot.create(:smart_proxy, features: features)

      params = {
        smart_proxy_id: proxy.id,
        insecure: true,
        jwt_expiration: 23,
      }

      post :create, params: params, session: set_session_user
      command = JSON.parse(@response.body)['command']

      assert_includes command, "curl -sS --insecure '#{proxy.url}/register"
      refute command.include?('smart_proxy_id')
      refute command.include?('insecure=true')
      refute command.include?('jwt_expiration')
    end

    context 'host_params' do
      let(:params) { { organization: taxonomies(:organization1).id, location: taxonomies(:location1).id } }

      before do
        CommonParameter.where(name: 'host_registration_insights').destroy_all
        CommonParameter.where(name: 'setup_remote_execution').destroy_all
      end

      test 'inherit value' do
        post :create, params: params, session: set_session_user

        refute JSON.parse(@response.body)['command'].include?('setup_insights')
        refute JSON.parse(@response.body)['command'].include?('setup_remote_execution')
      end

      test 'yes (override)' do
        post :create, params: params.merge(setup_insights: true, setup_remote_execution: true), session: set_session_user

        assert JSON.parse(@response.body)['command'].include?('setup_insights=true')
        assert JSON.parse(@response.body)['command'].include?('setup_remote_execution=true')
      end

      test 'no (override)' do
        post :create, params: params.merge(setup_insights: false, setup_remote_execution: false), session: set_session_user

        assert JSON.parse(@response.body)['command'].include?('setup_insights=false')
        assert JSON.parse(@response.body)['command'].include?('setup_remote_execution=false')
      end
    end

    context 'jwt' do
      test 'with default expiration' do
        post :create, session: set_session_user
        command = JSON.parse(@response.body)['command']
        parsed_token = command.scan(/(?<=Bearer )(.*)(?=.*)(?=\')/).flatten[0]
        assert JwtToken.new(parsed_token).decode['exp']
      end

      test 'with expiration' do
        post :create, params: { jwt_expiration: 23 }, session: set_session_user
        command = JSON.parse(@response.body)['command']
        parsed_token = command.scan(/(?<=Bearer )(.*)(?=.*)(?=\')/).flatten[0]
        assert JwtToken.new(parsed_token).decode['exp']
      end

      test 'unlimited' do
        post :create, params: { jwt_expiration: 'unlimited' }, session: set_session_user
        command = JSON.parse(@response.body)['command']
        parsed_token = command.scan(/(?<=Bearer )(.*)(?=.*)(?=\')/).flatten[0]

        refute JwtToken.new(parsed_token).decode['exp']
      end
    end
  end

  describe 'form_data' do
    test 'host groups & inherited_operatingsystem_id' do
      os = operatingsystems(:redhat)
      child_hg = FactoryBot.create(:hostgroup, parent: FactoryBot.create(:hostgroup, operatingsystem: os))
      get :form_data, session: set_session_user

      child_hg_from_response = JSON.parse(@response.body)['hostGroups']
                                   .find { |hg| hg['id'] == child_hg.id }
      assert_equal os.id, child_hg_from_response['inherited_operatingsystem_id']
    end

    test 'show smart proxies with Templates and Registration features only' do
      features = [FactoryBot.create(:feature, name: 'Registration'), FactoryBot.create(:feature, name: 'Templates')]
      proxy = FactoryBot.create(:smart_proxy, features: features)

      get :form_data, session: set_session_user
      response_proxies = JSON.parse(@response.body)['smartProxies']
      assert_equal response_proxies[0]['id'], proxy.id
    end
  end
end
