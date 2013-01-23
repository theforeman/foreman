require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
  end

  test "should get edit" do
    organization = Organization.new :name => "organization1"
    assert organization.save!
    get :edit, {:id => organization}, set_session_user
    assert_response :success
  end

  test "should update organization" do
    organization = taxonomies(:organization2)

    post :update, {:commit => "Submit", :id => organization.id, :organization => {:name => "New Name"} }, set_session_user
    updated_organization = Organization.find_by_id(organization.id)

    assert updated_organization.name = organization.name
    assert_redirected_to organizations_path
  end

  test "should not allow saving another organization with same name" do
    name = "organization_dup_name"
    organization = Organization.new :name => name
    assert organization.save!

    put :create, {:commit => "Submit", :organization => {:name => name} }, set_session_user
    assert @response.body.include? "has already been taken"
  end

  test "should delete null organization" do
    name = "organization1"
    organization = Organization.new :name => name
    assert organization.save!

    assert_difference('Organization.count', -1) do
      delete :destroy, {:id => organization}, set_session_user
      assert_contains flash[:notice], "Successfully destroyed #{organization}."
    end
  end

  # Assign All Hosts
  test "should assign all hosts with no organization to selected organization" do
    organization = taxonomies(:organization1)
    cnt_hosts_no_organization = Host.where(:organization_id => nil).count
    assert_difference "organization.hosts.count", cnt_hosts_no_organization do
      post :assign_all_hosts, {:id => organization.id}, set_session_user
    end
    assert_redirected_to :controller => :organizations, :action => :index
    assert_equal flash[:notice], "All hosts previously with no organization are now assigned to Organization 1"
  end
  test "should assign all hosts with no organization to selected organization and add taxable_taxonomies" do
    organization = taxonomies(:organization1)
    assert_difference "organization.taxable_taxonomies.count", 16 do
      post :assign_all_hosts, {:id => organization.id}, set_session_user
    end
  end

  # Assign Selected Hosts
  test "be able to select hosts with no organization to selected organization" do
    organization = taxonomies(:organization1)
    get :assign_hosts, {:id => organization.id}, set_session_user
    assert_response :success
  end
  test "assigned selected hosts with no organization to selected organization" do
    organization = taxonomies(:organization1)
    selected_hosts_no_organization_ids = Host.where(:organization_id => nil).limit(2).map(&:id)

    assert_difference "organization.hosts.count", 2 do
      put :assign_selected_hosts, {:id => organization.id,
                                   :organization => {:host_ids => selected_hosts_no_organization_ids}
                                  }, set_session_user
    end
    assert_redirected_to :controller => :organizations, :action => :index
    assert_equal flash[:notice], "Selected hosts are now assigned to Organization 1"
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
    assert_redirected_to :controller => :organizations, :action => :index
    assert_equal flash[:notice], "All mismatches between hosts and locations/organizations have been fixed"
    # check that there are no mismatches
    get :mismatches, {}, set_session_user
    assert_match "No hosts are mismatched", @response.body
  end

end
