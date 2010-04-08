require 'test_helper'

class AuthSourceLdapsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to auth_source_ldaps_url
  end

  def test_edit
    get :edit, :id => AuthSourceLdap.first
    assert_template 'edit'
  end

  def test_update_invalid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(false)
    put :update, :id => AuthSourceLdap.first
    assert_template 'edit'
  end

  def test_update_valid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(true)
    put :update, :id => AuthSourceLdap.first
    assert_redirected_to auth_source_ldaps_url
  end

  def test_destroy
    auth_source_ldap = AuthSourceLdap.first
    delete :destroy, :id => auth_source_ldap
    assert_redirected_to auth_source_ldaps_url
    assert !AuthSourceLdap.exists?(auth_source_ldap.id)
  end
end
