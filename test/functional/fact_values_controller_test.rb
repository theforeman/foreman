require 'test_helper'

class FactValuesControllerTest < ActionController::TestCase
  def setup
    User.current = nil
  end

  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_template FactValue.unconfigured? ? 'welcome' : 'index'
    assert_not_nil :fact_values
  end

  test 'user with viewer rights should succeed in viewing facts' do
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
    get :index, {}, set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end
end
