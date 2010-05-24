require 'test_helper'

class AuditsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_show
    get :show, {:id => Audit.first}, set_session_user
    assert_template 'show'
  end
end
