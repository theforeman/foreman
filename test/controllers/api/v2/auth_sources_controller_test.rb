require 'test_helper'

class Api::V2::AuthSourcesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, params: { }
    assert_response :success
    auth_sources = ActiveSupport::JSON.decode(@response.body)
    refute_empty auth_sources
    ids = auth_sources['results'].map { |hash| hash['id'] }
    assert_includes ids, auth_sources(:internal).id
    assert_includes ids, auth_sources(:external).id
    assert_includes ids, auth_sources(:one).id
    refute_includes ids, auth_sources(:hidden).id
  end
end
