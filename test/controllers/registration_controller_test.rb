require 'test_helper'

class RegistrationControllerTest < ActionController::TestCase
  test 'new' do
    get :new, session: set_session_user
    assert_response :success
    assert_template :new
  end

  describe 'create' do
    test 'create' do
      params = { organization: taxonomies(:organization1).id, location: taxonomies(:location1).id }
      post :create, params: params, session: set_session_user

      assert_response :success
      assert_template :create
    end

    context 'setup_insights_param' do
      let(:params) { { organization: taxonomies(:organization1).id, location: taxonomies(:location1).id } }

      before do
        CommonParameter.where(name: 'host_registration_insights').destroy_all
      end

      test 'without param' do
        post :create, params: params, session: set_session_user
        refute assigns(:command).include?('setup_insights')
      end

      test 'when host_registration_insights = nil && setup_insights = true' do
        post :create, params: params.merge(setup_insights: true), session: set_session_user
        assert assigns(:command).include?('setup_insights')
      end

      test 'when host_registration_insights = nil && setup_insights = false' do
        post :create, params: params.merge(setup_insights: false), session: set_session_user
        assert assigns(:command).include?('setup_insights')
      end

      test 'when host_registration_insights = true && setup_insights = true' do
        CommonParameter.create(name: 'host_registration_insights', key_type: 'boolean', value: true)
        post :create, params: params.merge(setup_insights: true), session: set_session_user
        refute assigns(:command).include?('setup_insights')
      end

      test 'when host_registration_insights = false && setup_insights = false' do
        CommonParameter.create(name: 'host_registration_insights', key_type: 'boolean', value: false)
        post :create, params: params.merge(setup_insights: false), session: set_session_user
        refute assigns(:command).include?('setup_insights')
      end

      test 'when host_registration_insights = true && setup_insights = false' do
        CommonParameter.create(name: 'host_registration_insights', key_type: 'boolean', value: true)
        post :create, params: params.merge(setup_insights: false), session: set_session_user
        assert assigns(:command).include?('setup_insights')
      end

      test 'when host_registration_insights = false && setup_insights = true' do
        CommonParameter.create(name: 'host_registration_insights', key_type: 'boolean', value: false)
        post :create, params: params.merge(setup_insights: true), session: set_session_user
        assert assigns(:command).include?('setup_insights')
      end
    end
  end
end
