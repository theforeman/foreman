require 'test_helper'

class StatisticsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test 'user with viewer rights should succeed in viewing statistics' do
    @request.session[:user] = users(:one).id
    users(:one).roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
    get :index
    assert_response :success
  end
end
