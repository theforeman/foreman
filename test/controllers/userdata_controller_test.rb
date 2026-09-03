require 'test_helper'

class UserdataControllerTest < ActionController::TestCase
  context '#user-data' do
    let(:organization) { FactoryBot.create(:organization) }
    let(:tax_location) { FactoryBot.create(:location) }
    let(:user_data_content) { 'template content user_data' }
    let(:cloud_init_content) { 'template content cloud-init' }
    let(:user_data_template_kind) do
      TemplateKind.where(name: 'user_data').first || FactoryBot.create(:template_kind, name: 'user_data')
    end
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
      @request.remote_ip = host.ip
    end

    context 'with user_data template' do
      test 'should get rendered userdata template' do
        get :userdata
        assert_response :success
        assert_equal user_data_content, @response.body
      end

      context 'with unknown ip address' do
        test 'should display an error' do
          @request.remote_ip = '198.51.100.1'
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

  context '#vendor-data' do
    let(:organization) { FactoryBot.create(:organization) }
    let(:tax_location) { FactoryBot.create(:location) }
    let(:vendor_data_content) { 'template content vendor_data' }
    let(:vendor_data_template_kind) do
      TemplateKind.where(name: 'vendor_data').first || FactoryBot.create(:template_kind, name: 'vendor_data')
    end
    let(:vendor_data_template) do
      FactoryBot.create(
        :provisioning_template,
        template_kind: vendor_data_template_kind,
        template: vendor_data_content,
        locations: [tax_location],
        organizations: [organization]
      )
    end
    let(:os) do
      FactoryBot.create(
        :operatingsystem,
        :with_associations,
        family: 'Redhat',
        provisioning_templates: [vendor_data_template]
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
        template_kind: vendor_data_template_kind,
        provisioning_template: vendor_data_template,
        operatingsystem: os
      )
      @request.remote_ip = host.ip
    end

    test 'should get rendered vendor-data template' do
      get :vendordata
      assert_response :success
      assert_equal vendor_data_content, @response.body
    end

    test 'should return an empty response when vendor-data template is not assigned' do
      host.operatingsystem.os_default_templates.where(template_kind: vendor_data_template_kind).delete_all

      get :vendordata
      assert_response :success
      assert_empty @response.body
    end

    test 'should return 404 for unknown ip address' do
      @request.remote_ip = '198.51.100.1'
      get :vendordata
      assert_response :not_found
      assert_includes @response.body, 'Could not find host for request 198.51.100.1'
    end

    test 'should get rendered vendor-data template when looking up host by mac' do
      @request.remote_ip = '198.51.100.1'
      get :vendordata, params: { mac: host.mac }
      assert_response :success
      assert_equal vendor_data_content, @response.body
    end

    test 'vendor-data route should route to vendordata action' do
      assert_routing '/userdata/vendor-data', controller: 'userdata', action: 'vendordata', format: 'text'
      assert_routing "/userdata/#{host.mac}/vendor-data", controller: 'userdata', action: 'vendordata', mac: host.mac, format: 'text'
    end
  end

  context '#metadata' do
    let(:host) { FactoryBot.create(:host, :managed) }
    setup do
      @request.remote_ip = host.ip
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
