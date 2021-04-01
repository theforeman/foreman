require 'test_helper'

class Api::V2::HostStatusesControllerTest < ActionController::TestCase
  setup do
    User.current = user
  end

  context 'with view_hosts permission' do
    let(:filter) { FactoryBot.create(:filter, permissions: Permission.where(name: 'view_hosts')) }
    let(:role) { FactoryBot.create(:role, filters: [filter]) }
    let(:user) { FactoryBot.create(:user, :with_mail, admin: false, roles: [role]) }

    test 'should get index' do
      get :index, session: set_session_user(user)
      assert_response :success
    end
  end

  context 'without view_hosts permission' do
    let(:user) { FactoryBot.create(:user, :with_mail, admin: false, roles: []) }

    test 'should not get index' do
      get :index, session: set_session_user(user)
      assert_response :forbidden
    end
  end
end
