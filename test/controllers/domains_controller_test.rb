require 'test_helper'

class DomainsControllerTest < ActionController::TestCase
  setup do
    @model = domains(:mydomain)
  end

  basic_index_test
  basic_new_test
  basic_edit_test

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

  def test_update_invalid
    Domain.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => @model.to_param, :domain => {:name => @model.name }}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Domain.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => @model.to_param, :domain => {:name => @model.name }}, set_session_user
    assert_redirected_to domains_url
  end

  def test_destroy
    domain = @model
    domain.hosts.clear
    domain.hostgroups.clear
    domain.subnets.clear
    delete :destroy, {:id => domain}, set_session_user
    assert_redirected_to domains_url
    assert !Domain.exists?(domain.id)
  end

  def user_with_viewer_rights_should_fail_to_edit_a_domain
    setup_users
    get :edit, {:id => @model.id}
    assert @response.status == '403 Forbidden'
  end

  def user_with_viewer_rights_should_succeed_in_viewing_domains
    setup_users
    get :index
    assert_response :success
  end

  test 'user with view_params rights should see parameters in a domain' do
    setup_user "edit", "domains"
    setup_user "view", "params"
    domain = FactoryGirl.create(:domain, :with_parameter)
    get :edit, {:id => domain.id}, set_session_user.merge(:user => users(:one).id)
    assert_not_nil response.body['Parameter']
  end

  test 'user without view_params rights should not see parameters in a domain' do
    setup_user "edit", "domains"
    domain = FactoryGirl.create(:domain, :with_parameter)
    get :edit, {:id => domain.id}, set_session_user.merge(:user => users(:one).id)
    assert_nil response.body['Parameter']
  end
end
