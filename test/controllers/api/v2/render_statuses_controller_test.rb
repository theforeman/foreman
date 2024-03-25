require 'test_helper'

class Api::V2::RenderStatusesControllerTest < ActionController::TestCase
  let(:render_statuses) { as_admin { FactoryBot.create_list(:render_status, 2) } }
  let(:hosts) { render_statuses.map(&:host) }
  let(:provisioning_templates) do
    render_statuses.map(&:provisioning_template).each do |provisioning_template|
      provisioning_template.locations << Location.all
      provisioning_template.organizations << Organization.all
    end
  end
  let(:role) do
    FactoryBot.create(:role, filters: permissions.map do |permission|
      FactoryBot.create(:filter, permissions: Permission.where(name: [permission]))
    end)
  end
  let(:user) { FactoryBot.create(:user, :with_mail, admin: false, roles: [role]) }

  describe 'GET /api/v2/hosts/:host_id/render_statuses' do
    let(:permissions) { [:view_hosts, :view_render_statuses] }

    test 'should get render statuses for given host only' do
      as_user user do
        get :index, params: { host_id: hosts.first.to_param }
      end

      assert_response :success
      assert_equal 1, ActiveSupport::JSON.decode(response.body)['total']
    end
  end

  describe 'GET /api/v2/hostgroups/:hostgroup_id/render_statuses' do
    let(:render_statuses) { as_admin { FactoryBot.create_list(:render_status, 2, :with_hostgroup) } }
    let(:hostgroups) { render_statuses.map(&:hostgroup) }
    let(:permissions) { [:view_hostgroups, :view_render_statuses] }

    test 'should get render statuses for given hostgroup only' do
      as_user user do
        get :index, params: { hostgroup_id: hostgroups.first.id }
      end

      assert_response :success
      assert_equal 1, ActiveSupport::JSON.decode(response.body)['total']
    end
  end

  describe 'GET /api/v2/provisioning_templates/:provisioning_template_id/render_statuses' do
    let(:permissions) { [:view_provisioning_templates, :view_render_statuses] }

    test 'should get render statuses for given provisioning template only' do
      as_user user do
        get :index, params: { provisioning_template_id: provisioning_templates.first.to_param }
      end

      assert_response :success
      assert_equal 1, ActiveSupport::JSON.decode(response.body)['total']
    end
  end
end
