# frozen_string_literal: true

require 'test_helper'

module ForemanRegister
  class HostsControllerTest < ActionController::TestCase
    let(:organization) { FactoryBot.create(:organization) }
    let(:tax_location) { FactoryBot.create(:location) }
    let(:template_content) { 'template content <%= @host.name %>' }
    let(:template_kind) { template_kinds(:registration) }
    let(:registration_template) do
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
          registration_template,
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
    let(:registration_token) { host.registration_token }

    describe '#register' do
      context 'with an associated template' do
        setup do
          FactoryBot.create(
            :os_default_template,
            template_kind: template_kind,
            provisioning_template: registration_template,
            operatingsystem: os
          )
        end

        it 'shows a registration script' do
          get :register, params: { token: registration_token }
          assert_response :success
          assert_not_nil assigns('host')
          assert_includes @response.body, 'template content'
          assert_includes @response.body, host.name
        end

        it 'enables build mode for the host' do
          get :register, params: { token: registration_token }
          assert_response :success
          assert_equal true, host.reload.build
        end

        it 'shows an error if no token is passed' do
          get :register
          assert_response :bad_request
        end
      end

      context 'without a template association' do
        it 'shows a not found error' do
          get :register, params: { token: registration_token }
          assert_response :not_found
        end
      end
    end
  end
end
