require 'test_helper'

class Api::V2::AuthSourceOidcsControllerTest < ActionController::TestCase
  setup do
    @auth_source = FactoryBot.create(:auth_source_oidc)
  end

  test 'lists providers without client secrets' do
    get :index

    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    result = response['results'].find { |item| item['id'] == @auth_source.id }
    assert_equal @auth_source.oidc_issuer, result['oidc_issuer']
    refute result.key?('oidc_client_secret')
  end

  test 'creates a provider' do
    assert_difference('AuthSourceOidc.count') do
      post :create, :params => { :auth_source_oidc => FactoryBot.attributes_for(:auth_source_oidc) }
    end

    assert_response :created
  end

  test 'updates a provider without returning its secret' do
    put :update, :params => { :id => @auth_source, :auth_source_oidc => { :oidc_scopes => 'openid email groups' } }

    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal 'openid email groups', response['oidc_scopes']
    refute response.key?('oidc_client_secret')
  end

  test 'tests provider discovery' do
    AuthSourceOidc.any_instance.stubs(:test_connection).returns(:message => 'success')

    put :test, :params => { :id => @auth_source }

    assert_response :success
    assert ActiveSupport::JSON.decode(@response.body)['success']
  end
end
