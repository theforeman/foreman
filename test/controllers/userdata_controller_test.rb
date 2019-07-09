require 'test_helper'

class UserdataControllerTest < ActionController::TestCase
  context '#user-data' do
    let(:organization) { FactoryBot.create(:organization) }
    let(:tax_location) { FactoryBot.create(:location) }
    let(:user_data_content) { 'template content user_data' }
    let(:cloud_init_content) { 'template content cloud-init' }
    let(:user_data_template_kind) { FactoryBot.create(:template_kind, name: 'user_data') }
    let(:cloud_init_template_kind) { FactoryBot.create(:template_kind, name: 'cloud-init') }
    let(:user_data_template) do
      FactoryBot.create(
        :provisioning_template,
        template_kind: user_data_template_kind,
        template: user_data_content,
        locations: [tax_location],
        organizations: [organization]
      )
    end
    let(:cloud_init_template) do
      FactoryBot.create(
        :provisioning_template,
        template_kind: cloud_init_template_kind,
        template: cloud_init_content,
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
          user_data_template,
          cloud_init_template,
        ]
      )
    end
    let(:host) do
      FactoryBot.create(
        :host,
        :managed,
        operatingsystem: os,
        organization: organization,
        location: tax_location
      )
    end

    setup do
      FactoryBot.create(
        :os_default_template,
        template_kind: user_data_template_kind,
        provisioning_template: user_data_template,
        operatingsystem: os
      )
      @request.env['REMOTE_ADDR'] = host.ip
    end

    context 'with user_data template' do
      test 'should get rendered userdata template' do
        get :userdata
        assert_response :success
        assert_equal user_data_content, @response.body
      end

      context 'with unknown ip address' do
        test 'should display an error' do
          @request.env['REMOTE_ADDR'] = '198.51.100.1'
          get :userdata
          assert_response :not_found
          assert_includes @response.body, 'Could not find host for request 198.51.100.1'
        end
      end
    end

    context 'with cloud-init template' do
      setup do
        FactoryBot.create(
          :os_default_template,
          :template_kind => cloud_init_template_kind,
          :provisioning_template => cloud_init_template,
          :operatingsystem => os
        )
      end

      test 'should get rendered cloud-init template' do
        get :userdata
        assert_response :success
        assert_equal cloud_init_content, @response.body
      end
    end
  end

  context '#metadata' do
    let(:host) { FactoryBot.create(:host, :managed) }
    setup do
      @request.env['REMOTE_ADDR'] = host.ip
    end

    test 'should get metadata of a host' do
      get :metadata
      assert_response :success
      response = @response.body
      parsed = YAML.safe_load(response)
      assert_equal host.mac, parsed['mac']
      assert_equal host.hostname, parsed['hostname']
    end
  end
end
