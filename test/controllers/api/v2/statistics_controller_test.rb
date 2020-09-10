require 'test_helper'

class Api::V2::StatisticsControllerTest < ActionController::TestCase
  test "should get statistics" do
    skip('Foreman statistics plugin is installed') if Foreman::Plugin.find(:foreman_statistics)
    get :index
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access /statistics API you need to install Foreman Statistics plugin'
  end
end
