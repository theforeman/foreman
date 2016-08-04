require 'test_helper'

class StatisticsControllerTest < ActionController::TestCase
  test 'user with viewer rights should succeed in viewing statistics' do
    @request.session[:user] = users(:one).id
    users(:one).roles = [Role.default, Role.find_by_name('Viewer')]
    get :index, {}, set_session_user
    assert_response :success
  end

  test 'index_json' do
    get :index, {:format => "json"}, set_session_user
    assert_response :success
    stats = ActiveSupport::JSON.decode(@response.body)
    assert stats.is_a?(Hash)
    %w{os_count Architecture\ Distribution env_count klass_count Number\ of\ CPUs Hardware mem_size mem_free swap_size swap_free}.each do |stat|
      assert_not_nil stats
    end
  end
end
