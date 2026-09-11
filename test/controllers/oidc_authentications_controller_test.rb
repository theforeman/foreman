require 'test_helper'

class OidcAuthenticationsControllerTest < ActionController::TestCase
  setup do
    @auth_source = FactoryBot.create(:auth_source_oidc)
  end

  test 'starts an authorization request and stores its state' do
    request = mock('authorization request')
    request.stubs(:session_data).returns(
      'auth_source_id' => @auth_source.id,
      'state' => 'state-1',
      'nonce' => 'nonce-1',
      'created_at' => Time.now.utc.to_i
    )
    request.stubs(:url).returns('https://idp.example.test/authorize')
    Oidc::AuthorizationRequest.stubs(:new).returns(request)

    post :start, :params => { :id => @auth_source.to_param }

    assert_redirected_to 'https://idp.example.test/authorize'
    assert_equal @auth_source.id, session[:oidc_authentications]['state-1']['auth_source_id']
  end

  test 'rejects a callback without matching state before exchanging a code' do
    Oidc::Authenticator.expects(:new).never

    get :callback, :params => { :state => 'unknown', :code => 'code' }

    assert_redirected_to login_users_path
    assert flash[:inline][:error].present?
  end

  test 'rejects an account linking callback without matching state' do
    user = FactoryBot.create(:user)
    Oidc::Authenticator.expects(:new).never

    assert_difference -> { Audit.where(:action => 'failed_link').count } do
      get :callback,
        :params => { :state => 'unknown', :code => 'code' },
        :session => { :user => user.id }
    end

    assert_redirected_to edit_user_path(:id => user)
    assert flash[:inline][:error].present?
  end

  test 'uses the configured Foreman URL for the redirect URI' do
    Setting.stubs(:[]).with(:foreman_url).returns('https://foreman.example.test/')

    assert_equal 'https://foreman.example.test/users/oidc/callback', @controller.send(:callback_url)
  end

  test 'authenticates a valid callback and synchronizes groups' do
    user = FactoryBot.create(:user)
    authentication = authentication_result
    authenticator = mock('authenticator')
    authenticator.expects(:authenticate).with('code', 'nonce-1', 'verifier').returns(authentication)
    Oidc::Authenticator.stubs(:new).returns(authenticator)
    resolver = mock('resolver')
    resolver.expects(:resolve).returns(Oidc::UserResolver::Result.new(:user => user, :created => false))
    Oidc::UserResolver.stubs(:new).returns(resolver)
    AuthSourceOidc.any_instance.expects(:sync_usergroups).with(user, ['admins'])

    get :callback,
      :params => { :state => 'state-1', :code => 'code' },
      :session => callback_session

    assert_redirected_to ApplicationHelper.current_hosts_path
    assert_equal user.id, session[:user]
    assert_equal @auth_source.id, session[:oidc_auth_source_id]
  end

  test 'links an additional provider after a fresh authentication' do
    user = FactoryBot.create(:user)
    authentication = authentication_result
    authenticator = mock('authenticator')
    authenticator.stubs(:authenticate).returns(authentication)
    Oidc::Authenticator.stubs(:new).returns(authenticator)
    linker = mock('identity linker')
    linker.expects(:link).returns(FactoryBot.build_stubbed(:oidc_identity, :user => user, :auth_source => @auth_source))
    Oidc::IdentityLinker.stubs(:new).returns(linker)
    AuthSourceOidc.any_instance.stubs(:sync_usergroups)

    get :callback,
      :params => { :state => 'state-1', :code => 'code' },
      :session => callback_session.merge(:user => user.id).deep_merge(
        :oidc_authentications => { 'state-1' => callback_flow.merge('link_user_id' => user.id) }
      )

    assert_redirected_to edit_user_path(:id => user)
  end

  private

  def authentication_result
    Oidc::Authenticator::Result.new(
      :claims => {},
      :subject => 'subject-1',
      :email => 'user@example.test',
      :email_verified => true,
      :groups => ['admins']
    )
  end

  def callback_flow
    {
      'auth_source_id' => @auth_source.id,
      'state' => 'state-1',
      'nonce' => 'nonce-1',
      'code_verifier' => 'verifier',
      'created_at' => Time.now.utc.to_i,
    }
  end

  def callback_session
    { :oidc_authentications => { 'state-1' => callback_flow } }
  end
end
