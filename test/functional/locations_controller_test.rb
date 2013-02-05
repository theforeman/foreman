require 'test_helper'

class LocationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
  end

  test "should get edit" do
    location = Location.new :name => "location1"
    assert location.save!
    get :edit, {:id => location}, set_session_user
    assert_response :success
  end

  test "should update location" do
    location = taxonomies(:location2)

    post :update, {:commit => "Submit", :id => location.id, :location => {:name => "New Name"} }, set_session_user
    updated_location = Location.find_by_id(location.id)

    assert updated_location.name = location.name
    assert_redirected_to locations_path
  end

  test "should not allow saving another location with same name" do
    name = "location_dup_name"
    location = Location.new :name => name
    assert location.save!

    put :create, {:commit => "Submit", :location => {:name => name} }, set_session_user
    assert @response.body.include? "has already been taken"
  end

  test "should delete null location" do
    name = "location1"
    location = Location.new :name => name
    assert location.save!

    assert_difference('Location.count', -1) do
      delete :destroy, {:id => location}, set_session_user
      assert_contains flash[:notice], "Successfully destroyed #{location}."
    end
  end

  # Assign All Hosts
  test "should assign all hosts with no location to selected location" do
    location = taxonomies(:location1)
    cnt_hosts_no_location = Host.where(:location_id => nil).count
    assert_difference "location.hosts.count", cnt_hosts_no_location do
      post :assign_all_hosts, {:id => location.id}, set_session_user
    end
    assert_redirected_to :controller => :locations, :action => :index
    assert_equal flash[:notice], "All hosts previously with no location are now assigned to Location 1"
  end
  test "should assign all hosts with no location to selected location and add taxable_taxonomies" do
    location = taxonomies(:location1)
    assert_difference "location.taxable_taxonomies.count", 16 do
      post :assign_all_hosts, {:id => location.id}, set_session_user
    end
  end

  # Assign Selected Hosts
  test "be able to select hosts with no location to selected location" do
    location = taxonomies(:location1)
    get :assign_hosts, {:id => location.id}, set_session_user
    assert_response :success
  end
  test "assigned selected hosts with no location to selected location" do
    location = taxonomies(:location1)
    selected_hosts_no_location_ids = Host.where(:location_id => nil).limit(2).map(&:id)

    assert_difference "location.hosts.count", 2 do
      put :assign_selected_hosts, {:id => location.id,
                                   :location => {:host_ids => selected_hosts_no_location_ids}
                                  }, set_session_user
    end
    assert_redirected_to :controller => :locations, :action => :index
    assert_equal flash[:notice], "Selected hosts are now assigned to Location 1"
  end

  # Mismatches
  test "should show all mismatches and button Fix All Mismatches if there are" do
    TaxableTaxonomy.delete_all
    get :mismatches, {}, set_session_user
    assert_response :success
    assert_match "Fix All Mismatches", @response.body
  end

  test "button Fix All Mismatches should work" do
    post :import_mismatches, {}, set_session_user
    assert_redirected_to :controller => :locations, :action => :index
    assert_equal flash[:notice], "All mismatches between hosts and locations/organizations have been fixed"
    # check that there are no mismatches
    get :mismatches, {}, set_session_user
    assert_match "No hosts are mismatched", @response.body
  end

  #Clone
  test "should present clone wizard" do
    location = taxonomies(:location1)
    get :clone_taxonomy, {:id => location.id}, set_session_user
    assert_response :success
    assert_match "Clone", @response.body
  end
  test "should clone location with assocations" do
    location = taxonomies(:location1)
    location_dup = location.clone

    assert_difference "Location.count", 1 do
      post :create, {:location => {:name => "location_dup_name",
                                 :environment_ids => location_dup.environment_ids,
                                 :hostgroup_ids => location_dup.hostgroup_ids,
                                 :subnet_ids => location_dup.hostgroup_ids,
                                 :domain_ids => location_dup.domain_ids,
                                 :medium_ids => location_dup.medium_ids,
                                 :user_ids => location_dup.user_ids,
                                 :smart_proxy_ids => location_dup.smart_proxy_ids,
                                 :config_template_ids => location_dup.config_template_ids,
                                 :compute_resource_ids => location_dup.compute_resource_ids,
                                 :organization_ids => location_dup.organization_ids
                               }
                   }, set_session_user
    end

    new_location = Location.order(:id).last
    assert_redirected_to :controller => :locations, :action => :step2, :id => new_location.id

    assert_equal new_location.environment_ids, location.environment_ids
    assert_equal new_location.hostgroup_ids, location.hostgroup_ids
    assert_equal new_location.environment_ids, location.environment_ids
    assert_equal new_location.domain_ids, location.domain_ids
    assert_equal new_location.medium_ids, location.medium_ids
    assert_equal new_location.user_ids, location.user_ids
    assert_equal new_location.smart_proxy_ids, location.smart_proxy_ids
    assert_equal new_location.config_template_ids, location.config_template_ids
    assert_equal new_location.compute_resource_ids, location.compute_resource_ids
    assert_equal new_location.organization_ids, location.organization_ids
  end

end
