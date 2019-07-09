require 'test_helper'

class UsergroupsControllerTest < ActionController::TestCase
  setup do
    as_admin { FactoryBot.create(:usergroup) }
    @model = Usergroup.first
  end

  basic_index_test
  basic_new_test
  basic_edit_test
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  def test_create_invalid
    Usergroup.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :usergroup => { :name => nil } }, session: set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Usergroup.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :usergroup => { :name => 'Managing users' } }, session: set_session_user
    assert_redirected_to usergroups_url
  end

  def test_update_invalid
    Usergroup.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => Usergroup.first, :usergroup => {:user_ids => ["", ""], :usergroup_ids => ["", ""]} }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Usergroup.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => Usergroup.first, :usergroup => {:user_ids => ["", ""], :usergroup_ids => ["", ""]} }, session: set_session_user
    assert_redirected_to usergroups_url
  end

  def test_destroy
    usergroup = Usergroup.first
    delete :destroy, params: { :id => usergroup }, session: set_session_user
    assert_redirected_to usergroups_url
    assert !Usergroup.exists?(usergroup.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a usergroup' do
    setup_user
    get :edit, params: { :id => Usergroup.first.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing usergroups' do
    setup_user
    get :index, session: set_session_user
    assert_response :success
  end

  test "changes should expire topbar cache" do
    user1 = FactoryBot.create(:user, :with_mail)
    user2 = FactoryBot.create(:user, :with_mail)
    usergroup = FactoryBot.create(:usergroup, :users => [user1, user2])
    User.any_instance.expects(:expire_topbar_cache).twice
    put :update, params: { :id => usergroup.id, :usergroup => {:admin => true } }, session: set_session_user
  end

  context "external user groups" do
    test 'a suggestion is shown if the LDAP source is not reachable' do
      AuthSourceLdap.any_instance.stubs(:valid_group? => true)
      external = FactoryBot.create(:external_usergroup)
      ExternalUsergroup.any_instance.expects(:refresh).
        raises(Net::LDAP::Error.new('foo'))
      put :update, params: { :id => external.usergroup_id, :usergroup => {
        :external_usergroups_attributes => {
          '0' => {
            'name' => external.name,
            'auth_source_id' => external.auth_source_id,
            'id' => external.id,
          },
        },
      }}, session: set_session_user

      assert_match(/.*refresh.*external.*verify.*reachable.*/, response.body)
      assert_template 'edit'
    end

    test 'are refreshed even when destroyed' do
      AuthSourceLdap.any_instance.stubs(:valid_group? => true)
      external = FactoryBot.create(:external_usergroup)
      ExternalUsergroup.any_instance.expects(:refresh).returns(true)

      put :update, params: { :id => external.usergroup_id, :usergroup => { :external_usergroups_attributes => {
        '0' => {'_destroy' => '1', 'name' => external.name, 'auth_source_id' => external.auth_source_id, 'id' => external.id},
      }}}, session: set_session_user
      assert_response :redirect
    end
  end

  test 'index supports search' do
    FactoryBot.create(:usergroup, :name => 'aaa')
    FactoryBot.create(:usergroup, :name => 'bbb')

    get :index, params: { :search => 'aaa' }, session: set_session_user

    assert_response :success

    assert_select 'table' do
      assert_select 'span', {:text => 'aaa'}
      assert_select 'span', {:text => 'bbb', :count => 0 }
    end
  end
end
