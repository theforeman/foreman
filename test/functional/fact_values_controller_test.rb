require 'test_helper'

class FactValuesControllerTest < ActionController::TestCase
  def fact_fixture
    Pathname.new("#{RAILS_ROOT}/test/fixtures/brslc022.facts.yaml").read
  end

  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_template FactValue.unconfigured? ? 'welcome' : 'index'
    assert_not_nil :fact_values
  end

  def test_create_invalid
    post :create, {:facts => fact_fixture[1..-1]}, set_session_user
    assert_response :bad_request
  end

  def test_create_valid
    post :create, {:facts => fact_fixture}, set_session_user
    assert_response :success
  end

  test 'user with viewer rights should succeed in viewing facts' do
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
    get :index
    assert_response :success
  end
end
