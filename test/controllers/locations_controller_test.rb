require 'test_helper'

class LocationsControllerTest < ActionController::TestCase
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test "should get index" do
    get :index, session: set_session_user
    assert_response :success
  end

  test "should get edit" do
    location = Location.new :name => "location1"
    as_admin do
      assert location.save!
      get :edit, params: { :id => location }, session: set_session_user
    end
    assert_response :success
  end

  test "should update location" do
    location = taxonomies(:location2)

    as_admin do
      post :update, params: { :commit => "Submit", :id => location.id, :location => {:name => "New Name"} }, session: set_session_user
    end

    updated_location = Location.find_by_id(location.id)

    assert_equal "New Name", updated_location.name
    assert_redirected_to locations_path
  end

  test "should not allow saving another location with same name" do
    as_admin do
      name = "location_dup_name"
      location = Location.new :name => name
      assert location.save!
      put :create, params: { :commit => "Submit", :location => {:name => name} }, session: set_session_user
    end

    assert @response.body.include? "has already been taken"
  end

  test "should delete null location" do
    name = "location1"
    location = Location.new :name => name

    as_admin do
      assert location.save!

      assert_difference('Location.count', -1) do
        delete :destroy, params: { :id => location }, session: set_session_user
        assert_match /Successfully deleted/, flash[:success]
      end
    end
  end

  test "should clear the session and switch to any if the user deleted their current location" do
    as_admin do
      location = Location.create!(:name => "random-location")
      Location.current = location
      delete :destroy, params: { :id => location.id }, session: set_session_user.merge(:location_id => location.id)
    end

    assert_nil Location.current
    assert_equal '', session[:location_id]
  end

  test "should save location on session expiry" do
    # login and select an org
    get :index, session: set_session_user
    session[:location_id] = taxonomies(:location1).id

    # session is expired, but try to load a page
    session[:expires_at] = 5.minutes.ago.to_i
    get :index

    # session is reset, redirected to login, but org id remains
    assert_redirected_to "/users/login"
    assert_match /Your session has expired, please login again/, flash[:inline][:warning]
    assert_equal session[:location_id], taxonomies(:location1).id
  end

  test "should display a warning if current location has been deleted" do
    get :index, session: set_session_user.merge(:location_id => 1234)
    assert_equal "Location you had selected as your context has been deleted", flash[:warning]
  end

  # Assign All Hosts
  test "should assign all hosts with no location to selected location" do
    location = taxonomies(:location1)
    cnt_hosts_no_location = Host.where(:location_id => nil).count
    assert_difference "location.hosts.count", cnt_hosts_no_location do
      post :assign_all_hosts, params: { :id => location.id }, session: set_session_user
    end
    assert_redirected_to :controller => :locations, :action => :index
    assert_equal flash[:success], "All hosts previously with no location are now assigned to Location 1"
  end

  test "should assign all hosts with no location to selected location and add taxable_taxonomies" do
    location = taxonomies(:location1)
    domain = FactoryBot.create(:domain, :locations => [taxonomies(:location2)])
    FactoryBot.create_list(:host, 2, :domain => domain, :location => nil)
    assert_difference "location.taxable_taxonomies.count", 1 do
      post :assign_all_hosts, params: { :id => location.id }, session: set_session_user
    end
  end

  # Assign Selected Hosts
  test "be able to select hosts with no location to selected location" do
    location = taxonomies(:location1)
    get :assign_hosts, params: { :id => location.id }, session: set_session_user
    assert_response :success
  end
  test "assigned selected hosts with no location to selected location" do
    location = taxonomies(:location1)
    hosts = FactoryBot.create_list(:host, 2, :location => nil)
    selected_hosts_no_location_ids = hosts.map(&:id)

    assert_difference "location.hosts.count", 2 do
      put :assign_selected_hosts, params: { :id => location.id,
                                            :location => {:host_ids => selected_hosts_no_location_ids},
                                          }, session: set_session_user
    end
    assert_redirected_to :controller => :locations, :action => :index
    assert_equal flash[:success], "Selected hosts are now assigned to Location 1"
  end

  # Mismatches
  test "should show all mismatches and button Fix All Mismatches if there are" do
    FactoryBot.create_list(:host, 2, :location => taxonomies(:location1))
    TaxableTaxonomy.delete_all
    get :mismatches, session: set_session_user
    assert_response :success
    assert_match "Fix All Mismatches", @response.body
  end

  test "button Fix All Mismatches should work" do
    post :import_mismatches, session: set_session_user
    assert_redirected_to :controller => :locations, :action => :index
    assert_equal flash[:success], "All mismatches between hosts and locations/organizations have been fixed"
    # check that there are no mismatches
    get :mismatches, session: set_session_user
    assert_match "No hosts are mismatched", @response.body
  end

  # Clone
  test "should present clone wizard" do
    location = taxonomies(:location1)
    get :clone_taxonomy, params: { :id => location.id }, session: set_session_user
    assert_response :success
    assert_match "Clone", @response.body
  end
  test "should clone location with associations" do
    location = taxonomies(:location1)
    location.organizations << taxonomies(:organization1)
    FactoryBot.create(:host, :location => nil)
    location_dup = location.clone

    assert_difference "Location.unscoped.count", 1 do
      post :create, params: {
        :location => location_dup.selected_ids.each { |_, v| v.uniq! }
          .merge(:name => 'location_dup_name'),
      }, session: set_session_user
    end

    new_location = Location.unscoped.order(:id).last
    assert_redirected_to :controller => :locations, :action => :step2, :id => new_location.to_param

    as_admin do
      [:hostgroup_ids, :domain_ids, :medium_ids, :user_ids, :smart_proxy_ids, :provisioning_template_ids, :compute_resource_ids, :organization_ids].each do |association|
        assert new_location.public_send(association).present?, "missing #{association}"
        assert_equal location.public_send(association).uniq.sort, new_location.public_send(association).uniq.sort, "#{association} is different"
      end
    end
  end

  test "should clear out Location.current and set current location to any in session" do
    @request.env['HTTP_REFERER'] = root_url
    get :clear, session: set_session_user
    assert_nil Location.current
    assert_equal '', session[:location_id]
    assert_redirected_to root_url
  end

  test "should nest a location" do
    location = taxonomies(:location1)
    get :nest, params: { :id => location.id }, session: set_session_user
    assert_response :success
    assert_template 'new'
    assert_equal location.id, assigns(:taxonomy).parent_id
  end

  test "changes should expire topbar cache" do
    user1 = FactoryBot.create(:user, :with_mail)
    user2 = FactoryBot.create(:user, :with_mail)
    location = as_admin { FactoryBot.create(:location, :users => [user1, user2]) }

    User.any_instance.expects(:expire_topbar_cache).times(2 + User.only_admin.count) # 2 users, all admins
    put :update, params: { :id => location.id, :location => {:name => "Topbar Loc" } }, session: set_session_user
  end

  test 'user with view_params rights should see parameters in a location' do
    location = FactoryBot.create(:location, :with_parameter, :organizations => [taxonomies(:organization1)])
    as_admin { location.users << users(:one) }
    setup_user "edit", "locations"
    setup_user "view", "params"
    get :edit, params: { :id => location.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_not_nil response.body['Parameter']
  end

  test 'user without view_params rights should not see parameters in an os' do
    location = FactoryBot.create(:location, :with_parameter)
    setup_user "edit", "locations"
    get :edit, params: { :id => location.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_nil response.body['Parameter']
  end

  test 'should allow empty array as param value of array field while updating location' do
    location = taxonomies(:location2)
    location.update(:organization_ids => [taxonomies(:organization2).id])
    saved_location = Location.find_by_id(location.id)
    assert_equal 1, saved_location.organization_ids.count
    put :update, params: { :id => location.id, :location => {:organization_ids => [""]} }, session: set_session_user
    updated_location = Location.find_by_id(location.id)
    assert_equal 0, updated_location.organization_ids.count
  end

  context 'wizard' do
    test 'redirects to step 2 if unassigned hosts exist' do
      host = FactoryBot.create(:host)
      host.update(:location => nil)

      location = FactoryBot.create(:location)
      Location.stubs(:current).returns(location)

      post :create, params: { :location => {:name => "test_loc"} }, session: set_session_user

      assert_redirected_to /step2/
      Location.unstub(:current)
    end

    test 'redirects to step 3 if no unassigned hosts exist' do
      post :create, params: { :location => {:name => "test_loc"} }, session: set_session_user

      assert_redirected_to /edit/
    end

    test 'redirects to step 3 if no permissins for hosts' do
      host = FactoryBot.create(:host)
      host.update(:location => nil)

      Host.stubs(:authorized).returns(Host.none)

      post :create, params: { :location => {:name => "test_loc"} }, session: set_session_user

      assert_redirected_to /edit/
      Host.unstub(:authorized)
    end
  end
end
