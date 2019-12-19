require 'test_helper'

class HttpProxiesControllerTest < ActionController::TestCase
  setup do
    @model = FactoryBot.create(:http_proxy)
  end

  basic_index_test
  basic_new_test
  basic_edit_test
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  def test_show
    get :edit, params: { :id => @model.id }, session: set_session_user

    assert_response :success
  end

  def test_destroy
    delete :destroy, params: { :id => @model.id }, session: set_session_user

    assert_response :found
    refute HttpProxy.find_by(:id => @model.id)
  end

  def test_create
    name = 'http_proxy_is_smart'
    post :create, params: { :http_proxy => { :name => name, :url => 'http://what????:5000' } }, session: set_session_user

    assert_redirected_to http_proxies_url
  end

  def test_update
    new_url = 'https://some_other_url'
    put :update, params: { :id => @model.id, :http_proxy => { :url => new_url } }, session: set_session_user

    assert_response :found
    assert_equal new_url, @model.reload.url
  end

  def test_update_location_and_organization
    location_id = taxonomies(:location1).id
    organization_id = taxonomies(:organization1).id

    put :update,
      params: {
        :id => @model.id,
        :http_proxy => { :location_ids => [location_id], :organization_ids => [organization_id] },
      },
      session: set_session_user

    assert_response :found
    assert_includes @model.reload.locations.pluck(:id), location_id
    assert_includes @model.reload.organizations.pluck(:id), organization_id
  end
end
