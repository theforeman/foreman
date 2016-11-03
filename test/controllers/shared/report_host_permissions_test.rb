module ReportHostPermissionsTest
  extend ActiveSupport::Concern
  included do
    context 'when user does not have permission to view hosts' do
      let :report do
        as_admin { FactoryGirl.create(:config_report) }
      end

      setup { setup_user('view', 'config_reports') }

      test 'cannot view any reports' do
        get :show, { :id => report.id }, set_session_user.merge(:user => User.current.id)
        assert_response :not_found
      end

      test 'cannot delete host reports' do
        setup_user 'destroy', 'config_reports'
        delete :destroy, { :id => report.id }, set_session_user.merge(:user => User.current.id)
        assert_response :not_found
      end
    end
  end
end
