require 'test_helper'

class HttpProxiesControllerTest < ActionController::TestCase
  setup do
    @model = FactoryGirl.create(:http_proxy)
  end

  basic_index_test
  basic_new_test
  basic_edit_test
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  def test_show
    get :edit, { :id => @model.id }, set_session_user

    assert_response :success
  end

  def test_destroy
    delete :destroy, { :id => @model.id }, set_session_user

    assert_response :found
    refute HttpProxy.find_by(:id => @model.id)
  end

  def test_create
    name = 'http_proxy_is_smart'
    post :create, { :http_proxy => { :name => name, :url => 'http://what????', :port => 5000 } }, set_session_user

    assert_response :found
    assert HttpProxy.find_by(:name => name)
  end

  def test_update
    new_url = 'https://some_other_url'
    put :update, { :id => @model.id, :http_proxy => { :url => new_url } }, set_session_user

    assert_response :found
    assert_equal new_url, @model.reload.url
  end
end
