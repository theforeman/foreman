require 'test_helper'

class AuditsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Audit.first
    assert_template 'show'
  end
end
