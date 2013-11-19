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

    assert_equal "New Name", updated_organization.name
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
      assert_match /Successfully deleted/, flash[:notice]
    end
  end

  test "should clear the session if the user deleted their current organization" do
    organization = Organization.create!(:name => "random-house")
    Organization.current = organization

    delete :destroy, {:id => organization.id}, set_session_user.merge(:organization_id => organization.id)

    assert_equal Organization.current, nil
    assert_equal session[:organization_id], nil
  end

  test "should display a warning if current organization has been deleted" do
    get :index, {}, set_session_user.merge(:organization_id => 1234)
    assert_equal "Organization you had selected as your context has been deleted.", flash[:warning]
  end

  # Assign All Systems
  test "should assign all systems with no organization to selected organization" do
    organization = taxonomies(:organization1)
    cnt_systems_no_organization = System.where(:organization_id => nil).count
    assert_difference "organization.systems.count", cnt_systems_no_organization do
      post :assign_all_systems, {:id => organization.id}, set_session_user
    end
    assert_redirected_to :controller => :organizations, :action => :index
    assert_equal flash[:notice], "All systems previously with no organization are now assigned to Organization 1"
  end

  test "should assign all systems with no organization to selected organization and add taxable_taxonomies" do
    organization = taxonomies(:organization1)
    assert_difference "organization.taxable_taxonomies.count", 15 do
      post :assign_all_systems, {:id => organization.id}, set_session_user
    end
  end

  # Assign Selected Systems
  test "be able to select systems with no organization to selected organization" do
    organization = taxonomies(:organization1)
    get :assign_systems, {:id => organization.id}, set_session_user
    assert_response :success
  end
  test "assigned selected systems with no organization to selected organization" do
    organization = taxonomies(:organization1)
    selected_systems_no_organization_ids = System.where(:organization_id => nil).limit(2).map(&:id)

    assert_difference "organization.systems.count", 2 do
      put :assign_selected_systems, {:id => organization.id,
                                   :organization => {:system_ids => selected_systems_no_organization_ids}
                                  }, set_session_user
    end
    assert_redirected_to :controller => :organizations, :action => :index
    assert_equal flash[:notice], "Selected systems are now assigned to Organization 1"
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
    assert_equal flash[:notice], "All mismatches between systems and locations/organizations have been fixed"
    # check that there are no mismatches
    get :mismatches, {}, set_session_user
    assert_match "No systems are mismatched", @response.body
  end

  #Clone
  test "should present clone wizard" do
    organization = taxonomies(:organization1)
    get :clone_taxonomy, {:id => organization.id}, set_session_user
    assert_response :success
    assert_match "Clone", @response.body
  end
  test "should clone organization with assocations" do
    organization = taxonomies(:organization1)
    organization_dup = organization.clone

    assert_difference "Organization.count", 1 do
      post :create, {:organization => {:name => "organization_dup_name",
                                 :environment_ids => organization_dup.environment_ids,
                                 :system_group_ids => organization_dup.system_group_ids,
                                 :subnet_ids => organization_dup.system_group_ids,
                                 :domain_ids => organization_dup.domain_ids,
                                 :medium_ids => organization_dup.medium_ids,
                                 :user_ids => organization_dup.user_ids,
                                 :smart_proxy_ids => organization_dup.smart_proxy_ids,
                                 :config_template_ids => organization_dup.config_template_ids,
                                 :compute_resource_ids => organization_dup.compute_resource_ids,
                                 :location_ids => organization_dup.location_ids
                               }
                   }, set_session_user
    end

    new_organization = Organization.order(:id).last
    assert_redirected_to :controller => :organizations, :action => :step2, :id => new_organization.id

    assert_equal new_organization.environment_ids, organization.environment_ids
    assert_equal new_organization.system_group_ids, organization.system_group_ids
    assert_equal new_organization.environment_ids, organization.environment_ids
    assert_equal new_organization.domain_ids, organization.domain_ids
    assert_equal new_organization.medium_ids, organization.medium_ids
    assert_equal new_organization.user_ids, organization.user_ids
    assert_equal new_organization.smart_proxy_ids, organization.smart_proxy_ids
    assert_equal new_organization.config_template_ids, organization.config_template_ids
    assert_equal new_organization.compute_resource_ids, organization.compute_resource_ids
    assert_equal new_organization.location_ids, organization.location_ids
  end

  test "should clear out Organization.current" do
    @request.env['HTTP_REFERER'] = root_url
    get :clear, {}, set_session_user
    assert_equal Organization.current, nil
    assert_equal session[:organization_id], nil
    assert_redirected_to root_url
  end
end
