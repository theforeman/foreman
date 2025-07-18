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

  def test_test_connection_success
    controller = HttpProxiesController.new
    controller.stubs(:http_proxy_params).returns({ url: 'https://some_url'})
    controller.stubs(:params).returns({test_url: "https://some.where.com"})
    RestClient::Request.stubs(:execute).returns(['example', 1])
    controller.expects(:render).with(:json => {:status => "success", :message => "HTTP Proxy connection successful."}, :status => :ok)
    controller.test_connection
  end

  def test_test_connection_failure
    controller = HttpProxiesController.new
    controller.stubs(:http_proxy_params).returns({ url: 'https://some_url'})
    controller.stubs(:params).returns({test_url: "https://some.where.com"})
    RestClient::Request.stubs(:execute).raises(StandardError.new('some error'))
    controller.expects(:render).with(:json => {:status => 'failure', :message => "some error"}, :status => :unprocessable_entity)
    controller.test_connection
  end

  context 'test_connection with  existing proxy' do
    test 'preserves password when empty password is provided' do
      existing_proxy = FactoryBot.create(:http_proxy,
        :name => 'existing_proxy',
        :url => 'https://old.example.com:8080',
        :username => 'olduser',
        :password => 'oldpassword'
      )

      HttpProxy.any_instance.stubs(:test_connection).returns(true)

      put :test_connection,
        params: {
          :http_proxy_id => existing_proxy.id,
          :http_proxy => {
            :name => 'updated_name',
            :url => 'https://new.example.com:8080',
            :username => 'newuser',
            :password => '', # Empty password in form (disabled field)
          },
          :test_url => 'https://test.example.com',
        },
        session: set_session_user

      assert_response :success
      response_json = JSON.parse(@response.body)
      assert_equal 'success', response_json['status']

      # Verify that the existing proxy object used for testing still has original password
      # but updated other attributes
      assigns(:http_proxy).tap do |proxy|
        assert_equal 'oldpassword', proxy.password, 'Password should be preserved from database'
        assert_equal 'https://new.example.com:8080', proxy.url, 'URL should be updated from form'
        assert_equal 'newuser', proxy.username, 'Username should be updated from form'
        assert_equal 'dummy', proxy.name, 'Name should be set to dummy for validation'
      end
    end
  end
end
