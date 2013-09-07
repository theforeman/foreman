require 'test_helper'

class FactValuesControllerTest < ActionController::TestCase
  def setup
    User.current = nil
  end

  fixtures

  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_template FactValue.unconfigured? ? 'welcome' : 'index'
    assert_not_nil :fact_values
  end

  test 'user with viewer rights should succeed in viewing facts' do
    users(:two).roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
    get :index, {}, set_session_user.merge(:user => users(:two).id)
    assert_response :success
  end

  test 'show nested fact json' do
    as_user :admin do
      get :index, {:format => "json", :fact_id => "kernelversion"}, set_session_user
    end
    factvalues =  ActiveSupport::JSON.decode(@response.body)
    assert_equal "fact = kernelversion", @request.params[:search]
    assert factvalues.is_a?(Hash)
    assert_equal [["kernelversion"]], factvalues.values.map(&:keys).uniq
    assert_response :success
  end

end
