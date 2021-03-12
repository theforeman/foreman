# frozen_string_literal: true

require 'test_helper'

module ForemanRegister
  class HostsControllerTest < ActionController::TestCase
    let(:organization) { FactoryBot.create(:organization) }
    let(:tax_location) { FactoryBot.create(:location) }
    let(:template_content) { 'template content <%= @host.name %>' }
    let(:template_kind) { template_kinds(:host_init_config) }
    let(:host_init_config_template) do
      FactoryBot.create(
        :provisioning_template,
        template_kind: template_kind,
        template: template_content,
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
          host_init_config_template,
        ]
      )
    end
    let(:host) do
      FactoryBot.create(
        :host,
        operatingsystem: os,
        organization: organization,
        location: tax_location
      )
    end
    let(:managed_host) do
      FactoryBot.create(
        :host,
        :managed,
        operatingsystem: os,
        organization: organization,
        location: tax_location
      )
    end
    let(:registration_token) { host.registration_token }

    setup do
      Setting[:default_host_init_config_template] = host_init_config_template.name
    end

    describe '#register' do
      context 'with an associated template' do
        it 'shows a registration script' do
          get :register, params: { token: registration_token }
          assert_response :success
          assert_not_nil assigns('host')
          assert_includes @response.body, 'template content'
          assert_includes @response.body, host.name
        end

        it 'enables build mode for the unmanaged host' do
          get :register, params: { token: registration_token }
          assert_response :success
          assert_equal true, host.reload.build
        end

        it 'enables build mode for the managed host' do
          get :register, params: { token: managed_host.registration_token }
          assert_response :success
          assert_equal true, managed_host.reload.build
        end

        it 'shows an error if no token is passed' do
          get :register
          assert_response :bad_request
        end
      end

      context 'without a template association' do
        it 'shows a not found error' do
          os.update(os_default_templates: [])
          get :register, params: { token: registration_token }
          assert_response :not_found
        end
      end

      context 'with error' do
        it 'no OS' do
          get :register, params: { token: FactoryBot.create(:host).registration_token }
          assert_response :bad_request
          assert_includes @response.body, 'Host is not associated with an operating system'
        end

        it 'template syntax' do
          host_init_config_template.update(template: "<% asda =!?== '2 % %>")
          get :register, params: { token: registration_token }
          assert_response :internal_server_error
          assert_includes @response.body, 'Foreman::Renderer::Errors::SyntaxError'
        end
      end
    end
  end
end
