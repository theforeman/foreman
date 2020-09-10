require 'test_helper'

class Api::GraphqlControllerTest < ActionController::TestCase
  test 'empty query' do
    post :execute, params: {}

    assert_response :success
    refute_empty json_errors
    assert_includes json_error_messages, 'No query string was present'
  end

  context 'without default user' do
    setup do
      User.current = nil
      reset_api_credentials
    end

    let(:user) { as_admin { FactoryBot.create(:user, :admin) } }

    context 'with valid credentials' do
      setup do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user.login, 'password')
      end

      it 'sets the admin user' do
        @controller.expects(:set_current_user).with(responds_with(:login, user.login)).returns(true)
        post :execute
      end

      it 'saves the user id into the session' do
        post :execute
        assert_equal user.id, session[:user]
      end
    end

    context 'with invalid credentials' do
      setup do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user.login, 'bute-force')
      end

      it 'prevents brute-force attempts' do
        @controller.expects(:log_bruteforce).once

        31.times do
          post :execute
        end

        assert_response :unauthorized
        assert_equal 'Bruteforce attempt.', JSON.parse(@response.body)['error']
      end
    end
  end
end
