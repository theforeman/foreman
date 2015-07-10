require 'test_helper'

class DomainsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Domain.any_instance.stubs(:valid?).returns(false)
    post :create, {:domain => {:name => nil}}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Domain.any_instance.stubs(:valid?).returns(true)
    post :create, {:domain => {:name => "MyDomain"}}, set_session_user
    assert_redirected_to domains_url
  end

  def test_edit
    get :edit, {:id => Domain.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Domain.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Domain.first.to_param, :domain => {:name => Domain.first.name }}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Domain.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Domain.first.to_param, :domain => {:name => Domain.first.name }}, set_session_user
    assert_redirected_to domains_url
  end

  def test_destroy
    domain = Domain.first
    domain.hosts.clear
    domain.hostgroups.clear
    domain.subnets.clear
    delete :destroy, {:id => domain}, set_session_user
    assert_redirected_to domains_url
    assert !Domain.exists?(domain.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  def user_with_viewer_rights_should_fail_to_edit_a_domain
    setup_users
    get :edit, {:id => Domain.first.id}
    assert @response.status == '403 Forbidden'
  end

  def user_with_viewer_rights_should_succeed_in_viewing_domains
    setup_users
    get :index
    assert_response :success
  end
end
