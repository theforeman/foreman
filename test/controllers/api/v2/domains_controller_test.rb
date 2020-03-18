require 'test_helper'

class Api::V2::DomainsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:domains)
  end

  test "should show domain" do
    get :show, params: { :id => Domain.first.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create valid domain" do
    post :create, params: { :domain => { :name => "domain.net" } }
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should not create invalid domain" do
    post :create, params: { :domain => { :fullname => "" } }
    assert_response :unprocessable_entity
  end

  test "should not create invalid dns_id" do
    invalid_proxy_id = SmartProxy.last.id + 100
    post :create, params: { :domain => { :name => "doma.in", :dns_id => invalid_proxy_id } }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_includes(show_response["error"]["full_messages"], "Dns Invalid smart-proxy id")
    assert_response :unprocessable_entity
  end

  test "should update valid domain" do
    put :update, params: { :id => Domain.first.to_param, :domain => { :name => "domain.new" } }
    assert_equal "domain.new", Domain.unscoped.first.name
    assert_response :success
  end

  test "should not update invalid domain" do
    put :update, params: { :id => Domain.first.to_param, :domain => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should not create invalid dns_id" do
    invalid_proxy_id = -1
    post :update, params: { :id => Domain.first.to_param, :domain => { :name => "domain.new", :dns_id => invalid_proxy_id } }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_includes(show_response["error"]["full_messages"], "Dns Invalid smart-proxy id")
    assert_response :unprocessable_entity
  end

  test "should destroy domain" do
    domain = Domain.first
    domain.hosts.clear
    domain.hostgroups.clear
    domain.subnets.clear
    delete :destroy, params: { :id => domain.to_param }
    domain = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    refute Domain.find_by_id(domain['id'])
  end

  context "taxonomy scope" do
    let (:mydomain) { domains(:mydomain) }
    let (:yourdomain) { domains(:yourdomain) }
    let (:loc) { FactoryBot.create(:location, domains: [mydomain, yourdomain]) }
    let (:org) { FactoryBot.create(:organization, domains: [mydomain]) }

    test "should get domains for location only" do
      get :index, params: { :location_id => loc.id }
      assert_response :success
      assert_equal loc.domains.length, assigns(:domains).length
      assert_same_elements assigns(:domains), loc.domains
    end

    test "should get domains for organization only" do
      get :index, params: { :organization_id => org.id }
      assert_response :success
      assert_equal org.domains.length, assigns(:domains).length
      assert_same_elements org.domains, assigns(:domains)
    end

    test "should get domains for both location and organization" do
      get :index, params: { :location_id => loc.id, :organization_id => org.id }
      assert_response :success
      assert_equal 1, assigns(:domains).length
      assert_equal assigns(:domains), [mydomain]
    end

    test "should show domain with correct child nodes including location and organization" do
      get :show, params: { :id => mydomain.to_param }
      assert_response :success
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert !show_response.empty?
      # assert child nodes are included in response
      ["locations", "organizations", "parameters", "subnets"].each do |node|
        assert show_response.key?(node), "'#{node}' child node should be in response but was not"
      end
    end
  end

  test "admin should be able to create domain in any context" do
    domain = FactoryBot.build_stubbed(:domain)
    post :create, params: { :domain => { :name => domain.name } }
    assert_response :success
    domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
    assert_empty domain.organizations
    assert_empty domain.locations
  end

  test "admin should be able to create domain in any context even if they have default context set but they explicitly override it" do
    domain = FactoryBot.build_stubbed(:domain)
    User.current.default_organization = taxonomies(:organization1)
    User.current.save
    post :create, params: { :organization_id => nil, :domain => { :name => domain.name } }
    assert_response :success
    domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
    assert_empty domain.organizations
    assert_empty domain.locations
  end

  test "user without view_params permission can't see domain parameters" do
    domain_with_parameter = FactoryBot.create(:domain, :with_parameter)
    setup_user "view", "domains"
    get :show, params: { :id => domain_with_parameter.to_param, :format => 'json' }
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see domain parameters" do
    domain_with_parameter = FactoryBot.create(:domain, :with_parameter)
    setup_user "view", "domains"
    setup_user "view", "params"
    get :show, params: { :id => domain_with_parameter.to_param, :format => 'json' }
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  context 'user with resource permissions scoped to single org and loc' do
    def setup
      @org1 = FactoryBot.create(:organization)
      @org2 = FactoryBot.create(:organization)
      @loc1 = FactoryBot.create(:location)
      @role = FactoryBot.build(:role)
      @role.add_permissions!([:view_domains, :edit_domains, :view_locations, :assign_locations, :view_organizations, :assign_organizations])
      @user = FactoryBot.create(:user, :organization_ids => [@org1.id], :location_ids => [@loc1.id], :roles => [@role])

      @domain1 = FactoryBot.create(:domain, :organization_ids => [@org1.id], :location_ids => [@loc1.id])
      @domain2 = FactoryBot.create(:domain, :organization_ids => [@org2.id], :location_ids => [@loc1.id])
    end

    test 'user can view domains from his organization and location' do
      as_user @user do
        get :index, params: { :organization_id => @org1.id, :location_id => @loc1.id }
      end
      assert_response :success
      domains = JSON.parse(response.body)['results'].map { |r| r['id'] }
      assert_includes domains, @domain1.id
      refute_includes domains, @domain2.id
    end

    test 'without default org and explicit parameter, user gets record from his only org' do
      as_user @user do
        get :index
      end
      assert_response :success
      domains = JSON.parse(response.body)['results'].map { |r| r['id'] }
      assert_includes domains, @domain1.id
      refute_includes domains, @domain2.id
    end

    context 'user permissions are scoped to single organization' do
      def setup
        super
        @role.organization_ids = [@org1.id]
        @role.location_ids = [@loc1.id]
        @role.save # to trigger taxonomy propagation to filters
      end

      test 'user can view domains from his organization and location' do
        as_user @user do
          get :index, params: { :organization_id => @org1.id, :location_id => @loc1.id }
        end
        assert_response :success
        domains = JSON.parse(response.body)['results'].map { |r| r['id'] }
        assert_includes domains, @domain1.id
        refute_includes domains, @domain2.id
      end

      test 'without default org and explicit parameter, user gets record from his only org' do
        as_user @user do
          get :index
        end
        assert_response :success
        domains = JSON.parse(response.body)['results'].map { |r| r['id'] }
        assert_includes domains, @domain1.id
        refute_includes domains, @domain2.id
      end
    end
  end

  context 'user with resource permissions scoped to 2 organizations' do
    def setup
      @org1 = FactoryBot.create(:organization)
      @org2 = FactoryBot.create(:organization)
      @org3 = FactoryBot.create(:organization)
      @loc1 = FactoryBot.create(:location)
      @role = FactoryBot.build(:role, :organization_ids => [@org1.id, @org2.id], :location_ids => [@loc1.id])
      # note that edit_organizations is required for API calls like POST /organization/1/domain, for GET we require only view_organizations
      @role.add_permissions!([:view_domains, :edit_domains, :view_locations, :assign_locations, :view_organizations, :assign_organizations, :create_domains, :edit_organizations, :edit_locations])
      @user = FactoryBot.create(:user, :organization_ids => [@org1.id, @org2.id], :location_ids => [@loc1.id], :roles => [@role])

      @domain1 = FactoryBot.create(:domain, :organization_ids => [@org1.id], :location_ids => [@loc1.id])
      @domain2 = FactoryBot.create(:domain, :organization_ids => [@org2.id], :location_ids => [@loc1.id])
      @domain3 = FactoryBot.create(:domain, :organization_ids => [@org3.id], :location_ids => [@loc1.id])
    end

    test 'user can view domains from organization they chose org 1 explicitly' do
      as_user @user do
        get :index, params: { :organization_id => @org1.id, :location_id => @loc1.id }
      end
      assert_response :success
      domains = JSON.parse(response.body)['results'].map { |r| r['id'] }
      assert_includes domains, @domain1.id
      refute_includes domains, @domain2.id
      refute_includes domains, @domain3.id
    end

    test 'user can view domains from organization they chose org 2 explicitly' do
      as_user @user do
        get :index, params: { :organization_id => @org2.id, :location_id => @loc1.id }
      end
      assert_response :success
      domains = JSON.parse(response.body)['results'].map { |r| r['id'] }
      refute_includes domains, @domain1.id
      assert_includes domains, @domain2.id
      refute_includes domains, @domain3.id
    end

    test 'user can view domains from his both organizations without explicitly specifying a parameter' do
      as_user @user do
        get :index
      end
      assert_response :success
      domains = JSON.parse(response.body)['results'].map { |r| r['id'] }
      assert_includes domains, @domain1.id
      assert_includes domains, @domain2.id
      refute_includes domains, @domain3.id
    end

    test 'user can create domains in specific organization of his but the current context must be specified' do
      domain = FactoryBot.build_stubbed(:domain)
      as_user @user do
        post :create, params: { :organization_id => @org1.id, :location_id => @loc1.id, :domain => { :name => domain.name, :organization_ids => [@org1.id], :location_ids => [@loc1.id] } }
      end
      assert_response :success
      domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
      assert_includes domain.organization_ids, @org1.id
      assert_includes domain.location_ids, @loc1.id
    end

    test 'user does not have to specify taxonomy if he is assigned to only one, it is selected automatically' do
      domain = FactoryBot.build_stubbed(:domain)
      as_user @user do
        post :create, params: { :organization_id => @org2.id, :domain => { :name => domain.name, :organization_ids => [@org2.id], :location_ids => [@loc1.id] } }
      end
      assert_response :success
      domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
      assert_includes domain.organization_ids, @org2.id
      assert_includes domain.location_ids, @loc1.id
    end

    test 'user can not create domain in taxonomy she does not belong to' do
      domain = FactoryBot.build_stubbed(:domain)
      as_user @user do
        post :create, params: { :domain => { :name => domain.name, :organization_ids => [@org3.id] } }
      end
      errors = JSON.parse(response.body)['error']['errors'].keys
      assert_response 422
      assert_includes errors, 'organization_ids'
    end

    test 'user can create domain in current context thanks to the fact organization_ids defaults to organization_id' do
      domain = FactoryBot.build_stubbed(:domain)
      as_user @user do
        post :create, params: { :organization_id => @org2.id, :domain => { :name => domain.name, :location_ids => [@loc1.id] } }
      end
      assert_response :success
      domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
      assert_includes domain.organization_ids, @org2.id
      assert_includes domain.location_ids, @loc1.id
    end

    test 'user can create domain in different organization than he set as a current organization' do
      domain = FactoryBot.build_stubbed(:domain)
      as_user @user do
        post :create, params: { :organization_id => @org1.id, :domain => { :name => domain.name, :organization_ids => [@org1.id, @org2.id], :location_ids => [@loc1.id] } }
      end
      assert_response :success
      domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
      assert_includes domain.organization_ids, @org1.id
      assert_includes domain.organization_ids, @org2.id
    end

    test 'user can create domain but current context is always preselected as organization_ids' do
      domain = FactoryBot.build_stubbed(:domain)
      as_user @user do
        post :create, params: { :organization_id => @org1.id, :domain => { :name => domain.name, :organization_ids => [@org2.id], :location_ids => [@loc1.id] } }
      end
      assert_response :success
      domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
      # this is because organization_id (current context) is preselected, consistent with UI
      assert_includes domain.organization_ids, @org1.id
      assert_includes domain.organization_ids, @org2.id
    end

    test 'user can not create resource in any context but they can use it to reset default value of organization_ids' do
      domain = FactoryBot.build_stubbed(:domain)
      as_user @user do
        post :create, params: { :organization_id => nil, :domain => { :name => domain.name, :organization_ids => [@org2.id], :location_ids => [@loc1.id] } }
      end
      assert_response :success
      domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
      refute_includes domain.organization_ids, @org1.id
      assert_includes domain.organization_ids, @org2.id
    end

    test 'user can not create resource without specifying organization explicitly' do
      # this would only work if user had default organization set, covered by test below
      domain = FactoryBot.build_stubbed(:domain)
      as_user @user do
        post :create, params: { :domain => { :name => domain.name } }
      end
      assert_response 422
      errors = JSON.parse(response.body)['error']['errors'].keys
      assert_includes errors, 'organization_ids'
    end

    context 'user has default organization set' do
      def setup
        super
        @user.default_organization = @org1
        @user.default_location = @loc1
        @user.save!
      end

      test 'user with default organization can override the selection with explicit parameter' do
        as_user @user do
          get :index, params: { :organization_id => @org2.id, :location_id => @loc1.id }
        end
        assert_response :success
        domains = JSON.parse(response.body)['results'].map { |r| r['id'] }
        refute_includes domains, @domain1.id
        assert_includes domains, @domain2.id
        refute_includes domains, @domain3.id
      end

      test 'user with default organization sees resources from it if he/she does not specify explicit parameter' do
        as_user @user do
          get :index, params: { :organization_id => @org1.id, :location_id => @loc1.id }
        end
        assert_response :success
        domains = JSON.parse(response.body)['results'].map { |r| r['id'] }
        assert_includes domains, @domain1.id
        refute_includes domains, @domain2.id
        refute_includes domains, @domain3.id
      end

      test 'user with default organization can enforce any context via explicit parameter' do
        as_user @user do
          get :index, params: { :organization_id => nil, :location_id => @loc1.id }
        end
        assert_response :success
        domains = JSON.parse(response.body)['results'].map { |r| r['id'] }
        assert_includes domains, @domain1.id
        assert_includes domains, @domain2.id
        refute_includes domains, @domain3.id
      end

      test 'user can still create domains in specific organization even if it is default one' do
        domain = FactoryBot.build_stubbed(:domain)
        as_user @user do
          post :create, params: { :organization_id => @org1.id, :domain => { :name => domain.name, :organization_ids => [@org1.id], :location_ids => [@loc1.id] } }
        end
        assert_response :success
        domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
        assert_includes domain.organization_ids, @org1.id
      end

      test 'user can create domain in other than default organization' do
        domain = FactoryBot.build_stubbed(:domain)
        as_user @user do
          post :create, params: { :organization_id => @org2.id, :domain => { :name => domain.name, :organization_ids => [@org2.id], :location_ids => [@loc1.id] } }
        end
        assert_response :success
        domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
        assert_includes domain.organization_ids, @org2.id
      end

      test 'user can create domain in other than default organization without need to specify organization_ids' do
        # preselected value is the currect context which overrides the default
        domain = FactoryBot.build_stubbed(:domain)
        as_user @user do
          post :create, params: { :organization_id => @org2.id, :domain => { :name => domain.name, :location_ids => [@loc1.id] } }
        end
        assert_response :success
        domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
        assert_includes domain.organization_ids, @org2.id
      end
    end
  end

  context 'hidden parameters' do
    test "should show a domain parameter as hidden unless show_hidden_parameters is true" do
      domain = FactoryBot.create(:domain)
      domain.domain_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => domain.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal '*****', show_response['parameters'].first['value']
    end

    test "should show a domain parameter as unhidden when show_hidden_parameters is true" do
      domain = FactoryBot.create(:domain)
      domain.domain_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => domain.id, :show_hidden_parameters => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 'bar', show_response['parameters'].first['value']
    end
  end

  test "should update existing domain parameters" do
    domain = FactoryBot.create(:domain)
    param_params = { :name => "foo", :value => "bar" }
    domain.domain_parameters.create!(param_params)
    put :update, params: { :id => domain.id, :domain => { :domain_parameters_attributes => [{ :name => param_params[:name], :value => "new_value" }] } }
    assert_response :success
    assert param_params[:name], domain.parameters.first.name
  end

  test "should delete existing domain parameters" do
    domain = FactoryBot.create(:domain)
    param_1 = { :name => "foo", :value => "bar" }
    param_2 = { :name => "boo", :value => "test" }
    domain.domain_parameters.create!([param_1, param_2])
    put :update, params: { :id => domain.id, :domain => { :domain_parameters_attributes => [{ :name => param_1[:name], :value => "new_value" }] } }
    assert_response :success
    assert_equal 1, domain.parameters.count
  end

  test "should get domains for searched location only" do
    taxonomies(:location2).domain_ids = [domains(:unuseddomain).id]
    get :index, params: { :search => "location_id=#{taxonomies(:location2).id}" }
    assert_response :success
    assert_equal taxonomies(:location2).domains.length, assigns(:domains).length
    assert_equal assigns(:domains), taxonomies(:location2).domains
  end

  test "should get domains when searching with organization_id" do
    domain = FactoryBot.create(:domain)
    org = FactoryBot.create(:organization)
    org.domain_ids = [domain.id]
    get :index, params: {:search => domain.name, :organization_id => org.id }
    assert_response :success
    assert_equal org.domains.length, assigns(:domains).length
    assert_equal assigns(:domains), org.domains
  end

  context "lone taxonomy assignment" do
    it 'assigns single taxonomies when only one present' do
      Location.stubs(:one?).returns(true)
      Organization.stubs(:one?).returns(true)
      post :create, params: { :domain => { :name => "domain.net" } }
      assert_response :created
      domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
      assert_equal 1, domain.locations.size
      assert_equal 1, domain.organizations.size
      assert_equal Location.first.id, domain.locations.first.id
      assert_equal Organization.first.id, domain.organizations.first.id
    end

    it "doesn't assign taxonomies when more than one present" do
      Location.stubs(:one?).returns(false)
      Organization.stubs(:one?).returns(false)
      post :create, params: { :domain => { :name => "domain.net" } }
      assert_response :created
      domain = Domain.unscoped.find(JSON.parse(response.body)['id'])
      assert_empty domain.locations
      assert_empty domain.organizations
    end
  end
end
