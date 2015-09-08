module ReportHostPermissionsTest
  extend ActiveSupport::Concern
  included do
    context 'when user does not have permission to view hosts' do
      setup { setup_user('view', 'reports') }

      test 'cannot view any reports' do
        report = FactoryGirl.create(:report)
        get :show, { :id => report.id }, set_session_user.merge(:user => User.current)
        assert_response :not_found
      end

      test 'cannot delete host reports' do
        setup_user 'destroy', 'reports'
        report = FactoryGirl.create(:report)
        delete :destroy, { :id => report.id }, set_session_user.merge(:user => User.current)
        assert_response :not_found
      end
    end
  end
end
