require 'test_helper'

class Api::V2::DomainsControllerTest < ActionController::TestCase

  #test that taxonomy scope works for api for domains
  def setup
    taxonomies(:location1).domain_ids = [domains(:mydomain).id, domains(:yourdomain).id]
    taxonomies(:organization1).domain_ids = [domains(:mydomain).id]
  end

  test "should get domains for location only" do
    get :index, {:location_id => taxonomies(:location1).id }
    assert_response :success
    assert_equal assigns(:domains).count, 2
    assert_equal assigns(:domains), [domains(:mydomain), domains(:yourdomain)]
  end

  test "should get domains for organization only" do
    get :index, {:organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal assigns(:domains).count, 1
    assert_equal assigns(:domains), [domains(:mydomain)]
  end

  test "should get domains for both location and organization" do
    get :index, {:location_id => taxonomies(:location1).id, :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal assigns(:domains).count, 1
    assert_equal assigns(:domains), [domains(:mydomain)]
  end

end
