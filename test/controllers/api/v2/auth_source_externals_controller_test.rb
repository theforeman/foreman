require 'test_helper'

class Api::V2::AuthSourceExternalsControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'new_name_external' }

  test "should get index" do
    get :index, params: { }
    assert_response :success
    assert_not_nil assigns(:auth_source_externals)
    auth_source_externals = ActiveSupport::JSON.decode(@response.body)
    refute_empty auth_source_externals
  end

  test "should show auth_source_external" do
    get :show, params: { :id => auth_sources(:external).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute_empty show_response
  end

  test "should update auth_source_external" do
    put :update, params: { :id => auth_sources(:external).to_param, :auth_source_external => valid_attrs }
    assert_response :success
    update_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal "new_name_external", update_response['name']
  end

  test 'allow access to auth source external objects' do
    setup_user('view', 'authenticators')
    auth_sources(:external).organizations = User.current.organizations
    auth_sources(:external).locations = User.current.locations
    get :show, params: { :id => auth_sources(:external).to_param }
    assert_response :success
  end

  test 'taxonomies can be set' do
    put :update, params: { :id => auth_sources(:external).to_param,
                   :auth_source_external => {
                     :organization_names => [taxonomies(:organization1).name],
                     :location_ids => [taxonomies(:location1).id] },
    }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    auth_source = AuthSource.find(show_response['id'])
    assert_include auth_source.locations, taxonomies(:location1)
    assert_include auth_source.organizations, taxonomies(:organization1)
  end
end
