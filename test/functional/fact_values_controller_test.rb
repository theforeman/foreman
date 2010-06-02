require 'test_helper'

class FactValuesControllerTest < ActionController::TestCase
  def fact_fixture
    Pathname.new("#{RAILS_ROOT}/test/fixtures/brslc022.facts.yaml").read
  end

  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_template 'index'
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

end
