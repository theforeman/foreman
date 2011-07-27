require 'test_helper'

class FactsControllerTest < ActionController::TestCase

  def test_index_json
    get :index, {:format => "json"}, set_session_user
    facts = ActiveSupport::JSON.decode(@response.body)
    assert facts.is_a?(Array)
    assert_response :success
  end

end
