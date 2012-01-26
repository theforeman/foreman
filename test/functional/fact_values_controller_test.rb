require 'test_helper'

class FactValuesControllerTest < ActionController::TestCase
  def fact_fixture
    Pathname.new("#{Rails.root}/test/fixtures/brslc022.facts.yaml").read
  end

  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_template FactValue.unconfigured? ? 'welcome' : 'index'
    assert_not_nil :fact_values
  end

  def test_create_invalid
    User.current = nil
    post :create, {:facts => fact_fixture[1..-1], :format => "yml"}
    assert_response :bad_request
  end

  def test_create_valid
    User.current = nil
    post :create, {:facts => fact_fixture, :format => "yml"}
    assert_response :success
  end

  test 'user with viewer rights should succeed in viewing facts' do
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
    get :index, {}, set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end

  test 'show nested fact json' do
    get :index, {:format => "json", :fact_id => "kernelversion"}, set_session_user
    factvalues =  ActiveSupport::JSON.decode(@response.body)
    assert_equal "fact = kernelversion", @request.params[:search]
    assert factvalues.is_a?(Hash)
    assert ["kernelversion"], factvalues.values.map(&:keys).uniq
    assert_response :success
  end


end
