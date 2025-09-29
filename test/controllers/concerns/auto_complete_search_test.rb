require 'test_helper'

class AutoCompleteSearchTest < ActionController::TestCase
  # Chosen at random as a representative of the controllers supporting autocompletion
  tests ::DomainsController

  test "only suggests options the user is permitted to see" do
    domain1 = FactoryBot.create(:domain)
    _domain2 = FactoryBot.create(:domain)
    setup_user('view', 'domains', "name = #{domain1.name}")

    get :auto_complete_search, session: set_session_user(:one), params: { search: "name =" }
    assert_predicate response, :successful?
    suggestions = ActiveSupport::JSON.decode(response.body)
    assert_equal 1, suggestions.length
    assert_equal suggestions.first['label'], "name = \"#{domain1.name}\""
  end
end
