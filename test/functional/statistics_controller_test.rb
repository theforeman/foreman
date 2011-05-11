require 'test_helper'

class StatisticsControllerTest < ActionController::TestCase

  test 'user with viewer rights should succeed in viewing statistics' do
    @request.session[:user] = users(:one).id
    users(:one).roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
    get :index
    assert_response :success
  end

  test 'index_json' do
    get :index, {:format => "json"}, set_session_user
    assert_response :success
    stats = ActiveSupport::JSON.decode(@response.body)
    assert stats.is_a?(Hash)
    %w{os_count arch_count env_count klass_count cpu_count model_count mem_size mem_free swap_size swap_free}.each do |stat|
          assert_not_nil stats["statistics"][stat]
    end
  end
end
