require 'test_helper'

class AuthSourceOidcsControllerTest < ActionController::TestCase
  setup do
    @model = FactoryBot.create(:auth_source_oidc)
  end

  basic_new_test
  basic_edit_test

  test 'creates a provider' do
    assert_difference('AuthSourceOidc.count') do
      post :create, :params => { :auth_source_oidc => FactoryBot.attributes_for(:auth_source_oidc) },
        :session => set_session_user
    end

    assert_redirected_to auth_sources_url
  end

  test 'does not return or erase an existing client secret on an unrelated update' do
    old_secret = @model.oidc_client_secret

    put :update, :params => { :id => @model, :auth_source_oidc => { :name => @model.name } },
      :session => set_session_user

    assert_redirected_to auth_sources_url
    assert_equal old_secret, @model.reload.oidc_client_secret
  end

  test 'tests provider discovery' do
    AuthSourceOidc.any_instance.stubs(:test_connection).returns(:success => true)

    put :test_connection,
      :params => { :auth_source_oidc => { :id => @model.id, :name => @model.name } },
      :session => set_session_user

    assert_response :success
  end

  test 'requires edit permission when testing an existing provider' do
    @controller.stubs(:params).returns(ActionController::Parameters.new(
      :action => 'test_connection', :auth_source_oidc => { :id => @model.id }
    ))

    assert_equal 'edit', @controller.send(:action_permission)
  end

  test 'requires create permission when testing a new provider' do
    @controller.stubs(:params).returns(ActionController::Parameters.new(
      :action => 'test_connection', :auth_source_oidc => {}
    ))

    assert_equal 'create', @controller.send(:action_permission)
  end

  test 'reports provider discovery errors' do
    AuthSourceOidc.any_instance.stubs(:test_connection).raises(Foreman::Exception, 'Discovery failed')

    put :test_connection,
      :params => { :auth_source_oidc => { :id => @model.id, :name => @model.name } },
      :session => set_session_user

    assert_response :unprocessable_entity
  end

  test 'does not delete a provider with linked identities' do
    FactoryBot.create(:oidc_identity, :auth_source => @model)

    assert_no_difference('AuthSourceOidc.count') do
      delete :destroy, :params => { :id => @model }, :session => set_session_user
    end
  end

  test 'does not delete a provider used as a primary authentication source' do
    FactoryBot.create(:user, :auth_source => @model)

    assert_no_difference('AuthSourceOidc.count') do
      delete :destroy, :params => { :id => @model }, :session => set_session_user
    end
  end
end
