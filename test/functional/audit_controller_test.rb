require 'test_helper'

class AuditControllerTest < ActionController::TestCase  

  def test_list
    get :list
    assert_response :success
  end

end
