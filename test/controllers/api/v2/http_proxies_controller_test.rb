require 'test_helper'

module Api
  module V2
    class HttpProxiesControllerTest < ActionController::TestCase
      let(:model) { FactoryGirl.create(:http_proxy) }

      def test_index
        get :index, {}, set_session_user

        assert_response :success
      end

      def test_show
        get :show, { :id => model.id }, set_session_user

        assert_response :success
      end

      def test_destroy
        delete :destroy, { :id => model.id }, set_session_user

        assert_response :success
        refute HttpProxy.find_by(:name => model.name)
      end

      def test_create
        name = 'http_proxy_is_smart'
        post :create, { :http_proxy => { :name => name, :url => 'http://what????', :port => 5000 } }, set_session_user

        assert_response :success
        assert HttpProxy.find_by(:name => name)
      end

      def test_update
        new_url = 'https://some_other_url'
        put :update, { :id => model.id, :http_proxy => { :url => new_url } }, set_session_user

        assert_response :success
        assert_equal new_url, model.reload.url
      end
    end
  end
end
