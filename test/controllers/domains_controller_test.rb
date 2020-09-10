require 'test_helper'
require 'nokogiri'

class DomainsControllerTest < ActionController::TestCase
  setup do
    @model = domains(:mydomain)
  end

  basic_index_test
  basic_new_test
  basic_edit_test
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  def test_create_invalid
    Domain.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :domain => {:name => nil} }, session: set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Domain.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :domain => {:name => "MyDomain"} }, session: set_session_user
    assert_redirected_to domains_url
  end

  def test_update_invalid
    Domain.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => @model.to_param, :domain => {:name => @model.name } }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Domain.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => @model.to_param, :domain => {:name => @model.name } }, session: set_session_user
    assert_redirected_to domains_url
  end

  def test_destroy
    domain = @model
    domain.hosts.clear
    domain.hostgroups.clear
    domain.subnets.clear
    delete :destroy, params: { :id => domain }, session: set_session_user
    assert_redirected_to domains_url
    assert !Domain.exists?(domain.id)
  end

  def user_with_viewer_rights_should_fail_to_edit_a_domain
    setup_users
    get :edit, params: { :id => @model.id }
    assert @response.status == '403 Forbidden'
  end

  def user_with_viewer_rights_should_succeed_in_viewing_domains
    setup_users
    get :index
    assert_response :success
  end

  test 'user with view_params rights should see parameters in a domain' do
    domain = FactoryBot.create(:domain, :with_parameter)
    setup_user "edit", "domains"
    setup_user "view", "params"
    get :edit, params: { :id => domain.id }, session: set_session_user.merge(:user => users(:one).id)
    html_doc = Nokogiri::HTML(response.body)
    assert_not_empty html_doc.css('a[href="#params"]')
  end

  test 'user without view_params rights should not see parameters in a domain' do
    domain = FactoryBot.create(:domain, :with_parameter)
    setup_user "edit", "domains"
    get :edit, params: { :id => domain.id }, session: set_session_user.merge(:user => users(:one).id)
    html_doc = Nokogiri::HTML(response.body)
    assert_empty html_doc.css('a[href="#params"]')
  end
end
