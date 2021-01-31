require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test "should get index" do
    get :index, session: set_session_user
    assert_response :success
  end

  test "should get edit" do
    organization = Organization.new :name => "organization1"
    as_admin do
      assert organization.save!
      get :edit, params: { :id => organization }, session: set_session_user
    end
    assert_response :success
  end

  test "index respects taxonomies" do
    org1 = FactoryBot.create(:organization)
    org2 = FactoryBot.create(:organization)
    user = FactoryBot.create(:user, :mail => 'a@b.c')
    user.organizations = [org1]
    filter = FactoryBot.create(:filter, :permissions => [Permission.find_by_name(:view_organizations)])
    user.roles << filter.role
    as_user user do
      get :index, session: set_session_user.merge(:user => User.current.id)
      assert_response :success
      assert_includes assigns(:taxonomies), org1
      refute_includes assigns(:taxonomies), org2
    end
  end

  test "should update organization" do
    organization = taxonomies(:organization2)

    post :update, params: { :commit => "Submit", :id => organization.id, :organization => {:name => "New Name"} }, session: set_session_user
    updated_organization = Organization.find_by_id(organization.id)

    assert_equal "New Name", updated_organization.name
    assert_redirected_to organizations_path
  end

  test "should not allow saving another organization with same name" do
    name = "organization_dup_name"
    organization = Organization.new :name => name
    as_admin do
      assert organization.save!
      put :create, params: { :commit => "Submit", :organization => {:name => name} }, session: set_session_user
    end

    assert @response.body.include? "has already been taken"
  end

  test "should delete null organization" do
    name = "organization1"
    organization = Organization.new :name => name
    as_admin do
      assert organization.save!

      assert_difference('Organization.count', -1) do
        delete :destroy, params: { :id => organization }, session: set_session_user
        assert_match /Successfully deleted/, flash[:success]
      end
    end
  end

  test "should clear the session if the user deleted their current organization and set any" do
    as_admin do
      organization = Organization.create!(:name => "random-house")
      Organization.current = organization

      delete :destroy, params: { :id => organization.id }, session: set_session_user.merge(:organization_id => organization.id)
    end

    assert_nil Organization.current
    assert_equal '', session[:organization_id]
  end

  test "should save organization on session expiry" do
    # login and select an org
    get :index, session: set_session_user
    session[:organization_id] = taxonomies(:organization1).id

    # session is expired, but try to load a page
    session[:expires_at] = 5.minutes.ago.to_i
    get :index

    # session is reset, redirected to login, but org id remains
    assert_redirected_to "/users/login"
    assert_match /Your session has expired, please login again/, flash[:inline][:warning]
    assert_equal session[:organization_id], taxonomies(:organization1).id
  end

  test "should display a warning if current organization has been deleted" do
    get :index, session: set_session_user.merge(:organization_id => 1234)
    assert_equal "Organization you had selected as your context has been deleted", flash[:warning]
  end

  # Assign All Hosts
  test "should assign all hosts with no organization to selected organization" do
    organization = taxonomies(:organization1)
    cnt_hosts_no_organization = Host.where(:organization_id => nil).count
    assert_difference "organization.hosts.count", cnt_hosts_no_organization do
      post :assign_all_hosts, params: { :id => organization.id }, session: set_session_user
    end
    assert_redirected_to :controller => :organizations, :action => :index
    assert_equal flash[:success], "All hosts previously with no organization are now assigned to Organization 1"
  end

  test "should assign all hosts with no organization to selected organization and add taxable_taxonomies" do
    organization = taxonomies(:organization1)
    domain = FactoryBot.create(:domain, :organizations => [taxonomies(:organization2)])
    FactoryBot.create_list(:host, 2, :domain => domain, :organization => nil)
    assert_difference "organization.taxable_taxonomies.count", 1 do
      post :assign_all_hosts, params: { :id => organization.id }, session: set_session_user
    end
  end

  # Assign Selected Hosts
  test "be able to select hosts with no organization to selected organization" do
    organization = taxonomies(:organization1)
    get :assign_hosts, params: { :id => organization.id }, session: set_session_user
    assert_response :success
  end
  test "assigned selected hosts with no organization to selected organization" do
    organization = taxonomies(:organization1)
    hosts = FactoryBot.create_list(:host, 2, :organization => nil)
    selected_hosts_no_organization_ids = hosts.map(&:id)

    assert_difference "organization.hosts.count", 2 do
      put :assign_selected_hosts, params: { :id => organization.id,
                                            :organization => {:host_ids => selected_hosts_no_organization_ids},
      }, session: set_session_user
    end
    assert_redirected_to :controller => :organizations, :action => :index
    assert_equal flash[:success], "Selected hosts are now assigned to Organization 1"
  end

  # Mismatches
  test "should show all mismatches and button Fix All Mismatches if there are" do
    FactoryBot.create_list(:host, 2, :organization => taxonomies(:organization1))
    TaxableTaxonomy.delete_all
    get :mismatches, session: set_session_user
    assert_response :success
    assert_match "Fix All Mismatches", @response.body
  end

  test "button Fix All Mismatches should work" do
    post :import_mismatches, session: set_session_user
    assert_redirected_to :controller => :organizations, :action => :index
    assert_equal flash[:success], "All mismatches between hosts and locations/organizations have been fixed"
    # check that there are no mismatches
    get :mismatches, session: set_session_user
    assert_match "No hosts are mismatched", @response.body
  end

  # Clone
  test "should present clone wizard" do
    organization = taxonomies(:organization1)
    get :clone_taxonomy, params: { :id => organization.id }, session: set_session_user
    assert_response :success
    assert_match "Clone", @response.body
  end
  test "should clone organization with associations" do
    organization = taxonomies(:organization1)
    organization.locations << taxonomies(:location1)
    FactoryBot.create(:host, :organization => nil)
    organization_dup = organization.clone

    assert_difference "Organization.unscoped.count", 1 do
      post :create, params: {
        :organization => organization_dup.selected_ids.each { |_, v| v.uniq! }
          .merge(:name => 'organization_dup_name'),
      }, session: set_session_user
    end

    new_organization = Organization.unscoped.order(:id).last
    assert_redirected_to :controller => :organizations, :action => :step2, :id => new_organization.to_param

    as_admin do
      [:hostgroup_ids, :domain_ids, :medium_ids, :user_ids, :smart_proxy_ids, :provisioning_template_ids, :compute_resource_ids, :location_ids].each do |association|
        assert new_organization.public_send(association).present?, "missing #{association}"
        assert_equal organization.public_send(association).uniq.sort, new_organization.public_send(association).uniq.sort, "#{association} is different"
      end
    end
  end

  test "should clear out Organization.current to any" do
    @request.env['HTTP_REFERER'] = root_url
    get :clear, session: set_session_user
    assert_nil Organization.current
    assert_equal '', session[:organization_id]
    assert_redirected_to root_url
  end

  test "changes should expire topbar cache" do
    user1 = FactoryBot.create(:user, :with_mail)
    user2 = FactoryBot.create(:user, :with_mail)
    organization = as_admin { FactoryBot.create(:organization, :users => [user1, user2]) }

    User.any_instance.expects(:expire_topbar_cache).times(2 + User.only_admin.count) # 2 users, all admins
    put :update, params: { :id => organization.id, :organization => {:name => "Topbar Org" } }, session: set_session_user
  end

  test 'user with view_params rights should see parameters in an os' do
    organization = FactoryBot.create(:organization, :with_parameter)
    as_admin { organization.users << users(:one) }
    setup_user "edit", "organizations"
    setup_user "view", "params"
    get :edit, params: { :id => organization.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_not_nil response.body['Parameter']
  end

  test 'user without view_params rights should not see parameters in an os' do
    organization = FactoryBot.create(:organization, :with_parameter)
    setup_user "edit", "organizations"
    get :edit, params: { :id => organization.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_nil response.body['Parameter']
  end

  test 'should allow empty array as param value of array field while updating organization' do
    organization = taxonomies(:organization2)
    organization.update(:smart_proxy_ids => [smart_proxies(:one).id])
    saved_organization = Organization.find_by_id(organization.id)
    assert_equal 1, saved_organization.smart_proxy_ids.count
    put :update, params: { :id => organization.id, :organization => {:smart_proxy_ids => [""]} }, session: set_session_user
    updated_organization = Organization.find_by_id(organization.id)
    assert_equal 0, updated_organization.smart_proxy_ids.count
  end

  context 'wizard' do
    test 'redirects to step 2 if unassigned hosts exist' do
      host = FactoryBot.create(:host)
      host.update(:organization => nil)

      organization = FactoryBot.create(:organization)
      Organization.stubs(:current).returns(organization)

      post :create, params: { :organization => {:name => "test_org"} }, session: set_session_user

      assert_redirected_to /step2/
      Organization.unstub(:current)
    end

    test 'redirects to step 3 if no unassigned hosts exist' do
      post :create, params: { :organization => {:name => "test_org"} }, session: set_session_user

      assert_redirected_to /edit/
    end

    test 'redirects to step 3 if no permissins for hosts' do
      host = FactoryBot.create(:host)
      host.update(:organization => nil)

      Host.stubs(:authorized).returns(Host.none)

      post :create, params: { :organization => {:name => "test_org"} }, session: set_session_user

      assert_redirected_to /edit/
      Host.unstub(:authorized)
    end
  end

  test 'should switch to newly created org' do
    name = 'test-org'
    put :create, params: { :commit => "Submit", :organization => { :name => name } }, session: set_session_user
    new_org = Organization.find_by :name => name
    assert_equal new_org.id, session[:organization_id]
  end
end
