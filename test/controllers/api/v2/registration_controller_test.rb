require 'test_helper'

class Api::V2::RegistrationControllerTest < ActionController::TestCase
  describe 'global registration' do
    test "should get template" do
      get :global
      assert_response :success
      assert_equal @response.body, templates(:global_registration).template
    end

    test "should render not_found" do
      Setting::Provisioning.any_instance.stubs(:value).returns('not-existing-template')
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
  end

  describe 'host registration' do
    let(:organization) { FactoryBot.create(:organization) }
    let(:tax_location) { FactoryBot.create(:location) }
    let(:template_kind) { template_kinds(:registration) }
    let(:registration_template) do
      FactoryBot.create(
        :provisioning_template,
        template_kind: template_kind,
        template: 'template content <%= @host.name %>',
        locations: [tax_location],
        organizations: [organization]
      )
    end
    let(:os) do
      FactoryBot.create(
        :operatingsystem,
        :with_associations,
        family: 'Redhat',
        provisioning_templates: [
          registration_template,
        ]
      )
    end

    let(:host_params) do
      { host: { name: 'centos-test.example.com',
                managed: false, build: false,
                organization_id: organization.id,
                location_id: tax_location.id,
                operatingsystem_id: os.id },
      }
    end

    setup do
      FactoryBot.create(
        :os_default_template,
        template_kind: template_kind,
        provisioning_template: registration_template,
        operatingsystem: os
      )
    end

    test 'should find and create host' do
      post :host, params: host_params, session: set_session_user
      assert_response :success
      assert_not_nil Host.find_by(name: host_params[:host][:name])
    end

    test 'should find and update host' do
      params = { host: { name: host_params[:host][:name], hostgroup_id: hostgroups(:unusual).id } }

      Host.create(host_params[:host])

      post :host, params: params, session: set_session_user
      assert_response :success
      assert Host.find_by(name: params[:host][:name]).hostgroup_id == params[:host][:hostgroup_id]
    end

    test 'should render template' do
      post :host, params: host_params, session: set_session_user
      assert_response :success
      assert_equal @response.body, "template content #{host_params[:host][:name]}"
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
      registration_template.update(template: "<% asda =!?== '2 % %>")
      post :host, params: host_params, session: set_session_user
      assert_response :internal_server_error
    end

    test 'with unsupported media_type' do
      post :host, params: host_params, session: set_session_user, as: :html
      assert_response :unsupported_media_type
    end
  end
end
