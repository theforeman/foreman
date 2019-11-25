require 'test_helper'

class AuthSourceExternalsControllerTest < ActionController::TestCase
  setup do
    @model = AuthSourceExternal.unscoped.first
  end

  basic_edit_test

  test "should update taxonomies" do
    auth_source_external_params = {:organization_ids => [taxonomies(:organization1).id],
                                   :location_names => [taxonomies(:location1).name] }
    put :update, params: { :id => AuthSourceExternal.unscoped.first,
                           :auth_source_external => auth_source_external_params },
        session: set_session_user
    assert_equal [taxonomies(:organization1)],
      AuthSourceExternal.unscoped.first.organizations.to_a
    assert_equal [taxonomies(:location1)],
      AuthSourceExternal.unscoped.first.locations.to_a
    assert_redirected_to auth_sources_url
  end
end
