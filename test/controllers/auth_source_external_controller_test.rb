require 'test_helper'

class AuthSourceExternalControllerTest < ActionController::TestCase
  setup do
    @model = AuthSourceExternal.unscoped.first
  end

  basic_index_test
  basic_edit_test
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  def test_update_invalid
    AuthSourceExternal.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => AuthSourceExternal.unscoped.first, :auth_source_external => {:name => AuthSourceExternal.unscoped.first.name} }, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    AuthSourceExternal.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => AuthSourceExternal.unscoped.first, :auth_source_external => {:name => AuthSourceExternal.unscoped.first.name} }, set_session_user
    assert_redirected_to auth_source_external_url
  end

  test 'taxonomies test' do
    auth_source_external_params = { :name => AuthSourceExternal.unscoped.first.name,
                                :organization_ids => [taxonomies(:organization1).id],
                                :location_names => [taxonomies(:location1).name] }
    put :update, { :id => AuthSourceExternal.unscoped.first,
                   :auth_source_external => auth_source_external_params },
        set_session_user
    assert_equal [taxonomies(:organization1)],
                 AuthSourceExternal.unscoped.first.organizations.to_a
    assert_equal [taxonomies(:location1)],
                 AuthSourceExternal.unscoped.first.locations.to_a
  end
end
