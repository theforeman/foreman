require 'test_helper'

class Api::V2::TrendsControllerTest < ActionController::TestCase
  [:index, :show].each do |action|
    test "should get index" do
      skip('Foreman statistics plugin is installed') if Foreman::Plugin.find(:foreman_statistics)
      get :index, params: {}
      assert_response :not_implemented
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal response['message'], 'To access /trends API you need to install Foreman Statistics plugin'
    end
  end

  test "should get index" do
    skip('Foreman statistics plugin is installed') if Foreman::Plugin.find(:foreman_statistics)
    post :create, params: {}
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access /trends API you need to install Foreman Statistics plugin'
  end

  test "should get index" do
    skip('Foreman statistics plugin is installed') if Foreman::Plugin.find(:foreman_statistics)
    delete :destroy, params: { id: 'rnd-123'}
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access /trends API you need to install Foreman Statistics plugin'
  end
end
