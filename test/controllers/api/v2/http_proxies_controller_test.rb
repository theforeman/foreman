require 'test_helper'

module Api
  module V2
    class HttpProxiesControllerTest < ActionController::TestCase
      let(:model) { FactoryBot.create(:http_proxy) }
      let (:myhttpproxy) { http_proxies(:myhttpproxy) }
      let (:yourhttpproxy) { http_proxies(:yourhttpproxy) }
      let (:loc) { FactoryBot.create(:location, http_proxies: [myhttpproxy, yourhttpproxy]) }
      let (:org) { FactoryBot.create(:organization, http_proxies: [myhttpproxy]) }

      def test_index
        get :index, session: set_session_user

        assert_response :success
      end

      def test_show
        get :show, params: { :id => model.id }, session: set_session_user

        assert_response :success
      end

      def test_destroy
        delete :destroy, params: { :id => model.id }, session: set_session_user

        assert_response :success
        refute HttpProxy.find_by(:name => model.name)
      end

      def test_create
        name = 'http_proxy_is_smart'
        post :create, params: { :http_proxy => { :name => name, :url => 'http://what????:5000' } }, session: set_session_user

        assert_response :created
        assert_equal JSON.parse(@response.body)['name'], name
      end

      def test_update
        new_url = 'https://some_other_url'
        put :update, params: { :id => model.id, :http_proxy => { :url => new_url } }, session: set_session_user

        assert_response :success
        assert_equal new_url, model.reload.url
      end

      def test_search_by_location
        get :index, params: { :location_id => loc.id }
        assert_response :success
        assert_equal loc.http_proxies.length, assigns(:http_proxies).length
        assert_same_elements assigns(:http_proxies), loc.http_proxies
      end
    end
  end
end
