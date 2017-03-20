require 'test_helper'

class Api::V2::SmartClassParametersControllerTest < ActionController::TestCase
  test "should get all smart class parameters" do
    get :index
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 4, results['results'].length
  end

  test "should get same smart class parameters in multiple environments once" do
    @env_class = FactoryBot.create(:environment_class,
                               :puppetclass => puppetclasses(:one),
                               :environment => environments(:testing),
                               :puppetclass_lookup_key => lookup_keys(:complex))
    get :index
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 4, results['results'].length
  end

  test "should get smart class parameters for a specific host" do
    @host = FactoryBot.create(:host,
                               :puppetclasses => [puppetclasses(:one)],
                               :environment => environments(:production))
    get :index, params: { :host_id => @host.to_param }
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "cluster", results['results'][0]['parameter']
  end

  test "should get :not_found for a non-existing host" do
    non_existing_id = 100000
    get :index, params: { :host_id => non_existing_id }
    assert_response :not_found
    results = ActiveSupport::JSON.decode(@response.body)
    assert_equal "Host with id '#{non_existing_id}' was not found", results["error"]["message"]
  end

  test "should get smart class parameters for a specific hostgroup" do
    get :index, params: { :hostgroup_id => hostgroups(:common).to_param }
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "cluster", results['results'][0]['parameter']
  end

  test "should get :not_found for a non-existing hostgroup" do
    non_existing_id = 100000
    get :index, params: { :hostgroup_id => non_existing_id }
    assert_response :not_found
    results = ActiveSupport::JSON.decode(@response.body)
    assert_equal "Hostgroup with id '#{non_existing_id}' was not found", results["error"]["message"]
  end

  test "should get smart class parameters for a specific puppetclass" do
    get :index, params: { :puppetclass_id => puppetclasses(:two).id }
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "custom_class_param", results['results'][0]['parameter']
  end

  test "should get same smart class parameters in multiple environments once for a specific puppetclass" do
    @env_class = FactoryBot.create(:environment_class,
                               :puppetclass => puppetclasses(:one),
                               :environment => environments(:testing),
                               :puppetclass_lookup_key => lookup_keys(:complex))
    get :index, params: { :puppetclass_id => puppetclasses(:one).id }
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "cluster", results['results'][0]['parameter']
  end

  test "should get :not_found for a non-existing puppetclass" do
    non_existing_id = 100000
    get :index, params: { :puppetclass_id => non_existing_id }
    assert_response :not_found
    results = ActiveSupport::JSON.decode(@response.body)
    assert_equal "Puppetclass with id '#{non_existing_id}' was not found", results["error"]["message"]
  end

  test "should get smart class parameters for a specific environment" do
    get :index, params: { :environment_id => environments(:production).id }
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 2, results['results'].count
    assert_equal ["cluster", "custom_class_param"], results['results'].map {|cp| cp["parameter"] }.sort
  end

  test "should get :not_found for a non-existing environment" do
    non_existing_id = 100000
    get :index, params: { :environment_id => non_existing_id }
    assert_response :not_found
    results = ActiveSupport::JSON.decode(@response.body)
    assert_equal "Environment with id '#{non_existing_id}' was not found", results["error"]["message"]
  end

  test "should get smart class parameters for a specific environment and puppetclass combination" do
    get :index, params: { :environment_id => environments(:production).id, :puppetclass_id => puppetclasses(:two).id }
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "custom_class_param", results['results'][0]['parameter']
  end

  test "should show specific smart class parameter by id" do
    get :show, params: { :id => lookup_keys(:five).to_param, :puppetclass_id => puppetclasses(:two).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show specific smart class parameter by parameter name when it is unique" do
    get :show, params: { :id => lookup_keys(:complex).key }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show specific smart class parameter by parameter name even if it is not unique" do
    get :show, params: { :id => lookup_keys(:five).key, :puppetclass_id => puppetclasses(:two).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show puppetclass name and id" do
    get :show, params: { :id => lookup_keys(:five).key, :puppetclass_id => puppetclasses(:two).id }
    assert_response :success
    results = ActiveSupport::JSON.decode(@response.body)
    assert_equal puppetclasses(:two).name, results['puppetclass_name']
    assert_equal puppetclasses(:two).id, results['puppetclass_id']
  end

  test "should update smart class parameter" do
    orig_value = lookup_keys(:five).default_value
    put :update, params: { :id => lookup_keys(:five).to_param, :smart_class_parameter => { :default_value => "33333" } }
    assert_response :success
    new_value = lookup_keys(:five).reload.default_value
    refute_equal orig_value, new_value
  end

  test "should update smart class parameter with use_puppet_default (compatibility test)" do
    Foreman::Deprecation.expects(:api_deprecation_warning).with('"use_puppet_default" was renamed to "omit"')
    orig_value = lookup_keys(:five).omit
    refute lookup_keys(:five).omit # check that the initial value is false
    put :update, params: { :id => lookup_keys(:five).to_param, :smart_class_parameter => { :use_puppet_default => "true" } }
    assert_response :success
    new_value = lookup_keys(:five).reload.omit
    refute_equal orig_value, new_value
  end

  test "should update smart class parameter with use_puppet_default (compatibility test)" do
    Foreman::Deprecation.expects(:api_deprecation_warning).with('"use_puppet_default" was renamed to "omit"')
    key = lookup_keys(:five)
    key.omit = true
    key.save!
    put :update, params: { :id => lookup_keys(:five).to_param, :smart_class_parameter => { :use_puppet_default => "false" } }
    assert_response :success
    new_value = lookup_keys(:five).reload.omit
    refute new_value
  end

  test "should return error if smart class parameter if it does not belong to specified puppetclass" do
    get :show, params: { :id => lookup_keys(:five).id, :puppetclass_id => puppetclasses(:one).id }
    assert_response 404
    # show_response = ActiveSupport::JSON.decode(@response.body)
    # assert !show_response.empty?
  end

  test "should get smart parameters with non admin user" do
    setup_user "view", "external_parameters"
    get :show, params: { :id => lookup_keys(:five).id }, session: set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end

  context 'hidden' do
    test "should show a smart class parameter as hidden unless show_hidden is true" do
      parameter = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing),:puppetclass => puppetclasses(:one), :puppetclass_lookup_key => parameter)
      get :show, params: { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['default_value']
    end

    test "should show a smart class parameter unhidden when show_hidden is true" do
      parameter = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing),:puppetclass => puppetclasses(:one), :puppetclass_lookup_key => parameter)
      setup_user "view", "puppetclasses"
      setup_user "view", "external_parameters"
      setup_user "edit", "external_parameters"
      get :show, params: { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id, :show_hidden => 'true' }, session: set_session_user.merge(:user => users(:one).id)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.default_value, show_response['default_value']
    end

    test "should show a smart class parameter parameter as hidden when show_hidden is true if user is not authorized" do
      parameter = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing),:puppetclass => puppetclasses(:one), :puppetclass_lookup_key => parameter)
      setup_user "view", "puppetclasses"
      setup_user "view", "external_parameters"
      get :show, params: { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id, :show_hidden => 'true' }, session: set_session_user.merge(:user => users(:one).id)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['default_value']
    end

    test "should show a smart class parameter's overrides unhidden when show_hidden is true" do
      parameter = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing),:puppetclass => puppetclasses(:one), :puppetclass_lookup_key => parameter)
      lookup_value = FactoryBot.create(:lookup_value, :lookup_key => parameter, :value => 'abc', :match => 'os=fake')
      setup_user "view", "puppetclasses"
      setup_user "view", "external_parameters"
      setup_user "edit", "external_parameters"
      get :show, params: { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id, :show_hidden => 'true' }, session: set_session_user.merge(:user => users(:one).id)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal lookup_value.value, show_response['override_values'][0]['value']
    end

    test "should show a smart class parameter's overrides hidden when show_hidden is false" do
      parameter = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing),:puppetclass => puppetclasses(:one), :puppetclass_lookup_key => parameter)
      lookup_value = FactoryBot.create(:lookup_value, :lookup_key => parameter, :value => 'abc', :match => 'os=fake')
      setup_user "view", "puppetclasses"
      setup_user "view", "external_parameters"
      setup_user "edit", "external_parameters"
      get :show, params: { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id, :show_hidden => 'false' }, session: set_session_user.merge(:user => users(:one).id)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal lookup_value.hidden_value, show_response['override_values'][0]['value']
    end
  end
end
