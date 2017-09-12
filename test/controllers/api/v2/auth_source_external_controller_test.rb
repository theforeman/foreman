require 'test_helper'

class Api::V2::AuthSourceExternalControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:auth_source_external)
    auth_source_external = ActiveSupport::JSON.decode(@response.body)
    refute auth_source_external.empty?
  end

  test "should show auth_source_external" do
    get :show, { :id => auth_sources(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end


  test "should update auth_source_external" do
    put :update, { :id => auth_sources(:one).to_param, :auth_source_external => valid_attrs }
    assert_response :success
  end

  context '*_authenticators filters' do
    test 'allow access to auth source external objects' do
      setup_user('view', 'authenticators')
      get :show, { :id => auth_sources(:one).to_param }
      assert_response :success
    end
  end

  test 'taxonomies can be set' do
    put :update, { :id => auth_sources(:one).to_param,
                   :organization_names => [taxonomies(:organization1).name],
                   :location_ids => [taxonomies(:location1).id] }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal taxonomies(:location1).id,
                 show_response['locations'].first['id']
    assert_equal taxonomies(:organization1).id,
                 show_response['organizations'].first['id']
  end
end
