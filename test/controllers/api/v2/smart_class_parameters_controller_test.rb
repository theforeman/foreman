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

  test_attributes :pid => 'c0378f1e-c215-4f85-892c-d21a8b5a7060'
  test "should get smart class parameters for a specific puppetclass" do
    get :index, params: { :puppetclass_id => puppetclasses(:two).id }
    assert_response :success
    assert_not_nil assigns(:smart_class_parameters)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "custom_class_param", results['results'][0]['parameter']
  end

  test_attributes :pid => 'e8b140c0-5c6a-404f-870c-8ebb128830ef'
  test "list parameters as non admin user" do
    filter1 = FactoryBot.build(:filter)
    filter1.permissions = Permission.where(:resource_type => ['Puppetclass'])
    filter2 = FactoryBot.build(:filter)
    filter2.permissions = Permission.where(:resource_type => ['PuppetclassLookupKey'])
    role = FactoryBot.build(:role)
    role.filters = [filter1, filter2]
    role.save!
    user = FactoryBot.create(:user)
    user.update_attribute :roles, [role]

    as_user user do
      get :index, params: { :puppetclass_id => puppetclasses(:two).id }
      assert_response :success
      assert_not_nil assigns(:smart_class_parameters)
      results = ActiveSupport::JSON.decode(@response.body)
      assert !results['results'].empty?
      assert_equal 1, results['results'].count
      assert_equal "custom_class_param", results['results'][0]['parameter']
    end
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
    assert_equal ["cluster", "custom_class_param"], results['results'].map { |cp| cp["parameter"] }.sort
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

  test_attributes :pid => '1140c3bf-ab3b-4da6-99fb-9c508cefbbd1'
  test "should update smart class parameter" do
    lookup_key = lookup_keys(:three)
    orig_value = lookup_key.default_value
    orig_parameter_type = lookup_key.parameter_type
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :parameter_type => "string", :default_value => "33333" } }
    assert_response :success
    lookup_key.reload
    refute_equal orig_value, lookup_key.default_value
    refute_equal orig_parameter_type, lookup_key.parameter_type
  end

  test_attributes :pid => '11d75f6d-7105-4ee8-b147-b8329cae4156'
  test "should not set avoid duplicates for non supported types" do
    lookup_key = lookup_keys(:five)
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :parameter_type => "string", :default_value => RFauxFactory.gen_alpha, :avoid_duplicates => true } }
    assert_response :internal_server_error, 'Can set avoid duplicated for non supported types'
    assert_includes JSON.parse(response.body)['error']['message'], 'Validation failed: Avoid duplicates can only be set for arrays that have merge_overrides set to true'
    assert_equal lookup_key.reload.avoid_duplicates, false
  end

  test_attributes :pid => 'd7b1c336-bd9f-40a3-a573-939f2a021cdc'
  test "should not set merge overrides for non supported types" do
    lookup_key = lookup_keys(:five)
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :parameter_type => "string", :default_value => RFauxFactory.gen_alpha, :merge_overrides => true } }
    assert_response :internal_server_error, 'Can set merge overrides for non supported types'
    assert_includes JSON.parse(response.body)['error']['message'], 'Validation failed: Merge overrides can only be set for array, hash, json or yaml'
    assert_equal lookup_key.reload.merge_overrides, false
  end

  test_attributes :pid => 'fc1ab905-b213-4b67-b886-b10c9cc0379f'
  test "should not set merge default if merge overrides is not set" do
    lookup_key = lookup_keys(:five)
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :parameter_type => "string", :default_value => RFauxFactory.gen_alpha, :merge_default => true } }
    assert_response :internal_server_error, 'Can set merge default if merge overrides is not set'
    assert_includes JSON.parse(response.body)['error']['message'], 'Validation failed: Merge default can only be set when merge overrides is set'
    lookup_key = LookupKey.unscoped.find_by_id(lookup_keys(:five).id)
    assert_equal lookup_key.reload.merge_default, false
  end

  test_attributes :pid => 'f4d56d31-ac48-495f-9e56-545f274a060f'
  test "should not set default value if override is false" do
    lookup_key = lookup_keys(:one)
    assert_equal lookup_key.override, false
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :default_value => RFauxFactory.gen_alpha } }
    assert_response :internal_server_error, 'Can set default value if override is not set'
    assert_includes JSON.parse(response.body)['error']['message'], 'Validation failed: Override must be true to edit the parameter'
  end

  test_attributes :pid => '7f0ab885-5520-4431-a916-f739c0498a5b'
  test "should not update parameter data with invalid values" do
    lookup_key = lookup_keys(:five)
    default_value = RFauxFactory.gen_alphanumeric
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :parameter_type => "boolean", :default_value => default_value } }
    assert_response :internal_server_error, 'Can set invalid parameter type / default value'
    assert_includes JSON.parse(response.body)['error']['message'], 'Validation failed: Default value is invalid'
    lookup_key = LookupKey.unscoped.find_by_id(lookup_key.id)
    assert_not_equal lookup_key.reload.default_value, default_value
  end

  test_attributes :pid => '75b1dc0b-2287-4b99-b8dc-e50b83355819'
  test "should not update default value if not in list" do
    lookup_key = lookup_keys(:five)
    default_value = RFauxFactory.gen_alphanumeric
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :parameter_type => "string", :default_value => default_value, :validator_type => "list", :validator_rule => "5, test" } }
    assert_response :internal_server_error, 'Can set default value if value not in validator list'
    assert_includes JSON.parse(response.body)['error']['message'], "Validation failed: Default value #{default_value} is not one of"
    assert_not_equal lookup_key.reload.default_value, default_value
  end

  test_attributes :pid => '99628b78-3037-4c20-95f0-7ce5455093ac'
  test "should not update default value if not match regexp" do
    lookup_key = lookup_keys(:five)
    default_value = RFauxFactory.gen_alpha
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :parameter_type => "string", :default_value => default_value, :validator_type => "regexp", :validator_rule => "[0-9]" } }
    assert_response :internal_server_error, 'Can set default value if value not in validator regexp'
    assert_includes JSON.parse(response.body)['error']['message'], 'Validation failed: Default value is invalid'
    assert_not_equal lookup_key.reload.default_value, default_value
  end

  test_attributes :pid => 'e46a12cb-b3ea-42eb-b1bb-b750655b6a4a'
  test "should not update default type with invalid value" do
    default_value = RFauxFactory.gen_alpha
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :puppetclass => puppetclasses(:two))
    FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => RFauxFactory.gen_alpha, :match => 'domain=example.com')
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :parameter_type => "boolean", :default_value => default_value } }
    assert_response :internal_server_error, 'Can set default type with invalid value'
    assert_includes JSON.parse(response.body)['error']['message'], 'Validation failed: Default value is invalid, Lookup values is invalid'
    lookup_key.reload
    assert_not_equal lookup_key.default_value, default_value
    assert_not_equal lookup_key.parameter_type, "boolean"
  end

  test_attributes :pid => 'a5e89e86-253f-4254-9ebb-eefb3dc2c2ab'
  test "should not update matcher with value not in list" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :default_value => 'list', :puppetclass => puppetclasses(:two))
    FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => 'myexample', :match => 'domain=example.com')
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :default_value => 50, :validator_type => 'list', :validator_rule => '25, example, 50' } }
    assert_includes JSON.parse(response.body)['error']['message'], 'Validation failed: Lookup values is invalid'
  end

  test_attributes :pid => '08820c89-2b93-40f1-be17-0bd38c519e90'
  test "should not update matcher with value not matching regex" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :default_value => 'regex', :puppetclass => puppetclasses(:two))
    FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => 'myexample', :match => 'domain=test.com')
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :default_value => RFauxFactory.gen_numeric_string, :validator_type => 'regexp', :validator_rule => '[0-9]' } }
    assert_includes JSON.parse(response.body)['error']['message'], 'Validation failed: Lookup values is invalid'
  end

  test_attributes :pid => '80bf52df-e678-4384-a4d5-7a88928620ce'
  test "should set avoid duplicates for supported types" do
    put :update, params: { :id => lookup_keys(:five).id, :smart_class_parameter => { :override => true, :parameter_type => "array", :default_value => "[#{RFauxFactory.gen_alpha}, #{RFauxFactory.gen_alpha}]", :avoid_duplicates => true, :merge_overrides => true } }
    assert_response :success
    assert_equal JSON.parse(response.body)['avoid_duplicates'], true, "Can't set avoid duplicates"
  end

  test_attributes :pid => 'ae1c8e2d-c15d-4325-9aa6-cc6b091fb95a'
  test "should set merge overrides for supported types" do
    put :update, params: { :id => lookup_keys(:five).id, :smart_class_parameter => { :override => true, :parameter_type => "array", :default_value => "[#{RFauxFactory.gen_alpha}, #{RFauxFactory.gen_alpha}]", :merge_overrides => true, :merge_default => true } }
    assert_response :success
    assert_equal JSON.parse(response.body)['merge_overrides'], true, "Can't set merge overrides"
    assert_equal JSON.parse(response.body)['merge_default'], true, "Can't set merge default"
  end

  test_attributes :pid => 'b6882658-9201-4e87-978a-0195a99ec07d'
  test "should hide empty default value" do
    put :update, params: { :id => lookup_keys(:five).id, :smart_class_parameter => { :override => true, :default_value => "", :hidden_value => true } }
    assert_response :success
    assert_equal JSON.parse(response.body)['hidden_value?'], true
    assert_equal JSON.parse(response.body)['default_value'], '*****'
    get :show, params: { :id => lookup_keys(:five).id, :show_hidden => true }
    assert_equal JSON.parse(response.body)['default_value'], ''
  end

  test_attributes :pid => '0cb8ab59-7910-4573-9dea-2e489d1578d4'
  test "should hide default value" do
    put :update, params: { :id => lookup_keys(:five).id, :smart_class_parameter => { :override => true, :default_value => RFauxFactory.gen_alpha, :hidden_value => true } }
    assert_response :success
    assert_equal JSON.parse(response.body)['hidden_value?'], true
    assert_equal JSON.parse(response.body)['default_value'], '*****'
  end

  test_attributes :pid => '3ffbf403-dac9-4172-a586-82267765abd8'
  test "impact parameter delete attribute" do
    hostgroup_name = RFauxFactory.gen_alpha
    match = "hostgroup=#{hostgroup_name}"
    match_value = RFauxFactory.gen_alpha
    hostgroup = FactoryBot.create(:hostgroup, :name => hostgroup_name, :environment => environments(:production))
    puppetclass = FactoryBot.create(:puppetclass)
    hostgroup.puppetclasses << puppetclass
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :default_value => 'list', :puppetclass => puppetclasses(:two))
    FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => match_value, :match => match)
    lookup_key = LookupKey.unscoped.find_by_id(lookup_key.id)
    assert_equal lookup_key.override_values.first.match, match
    assert_equal lookup_key.override_values.first.value, match_value
    hostgroup.destroy
    lookup_key.reload
    assert_equal lookup_key.override_values.length, 0
    hostgroup = FactoryBot.create(:hostgroup, :name => hostgroup_name, :environment => environments(:production))
    puppetclass = FactoryBot.create(:puppetclass)
    hostgroup.puppetclasses << puppetclass
    get :show, params: { :id => lookup_key.id }
    assert_equal JSON.parse(response.body)['override_values_count'], 0
  end

  test_attributes :pid => 'eaa11546-79df-452e-9552-5b2507a27b48'
  test "should set override" do
    value = RFauxFactory.gen_alpha
    put :update, params: { :id => lookup_keys(:five).id, :smart_class_parameter => { :override => true, :parameter_type => "string", :default_value => value } }
    assert_response :success
    assert_equal JSON.parse(response.body)['override'], true
    assert_equal JSON.parse(response.body)['default_value'], value
  end

  test_attributes :pid => '7261b409-b482-41ba-934d-4b724e8113ac'
  test "should set puppet default" do
    put :update, params: { :id => lookup_keys(:five).id, :smart_class_parameter => { :override => true, :omit => true} }
    assert_response :success
    assert_equal JSON.parse(response.body)['omit'], true
  end

  test_attributes :pid => '9018d624-07f2-4fb2-b421-8888c7d324a7'
  test "should remove matcher" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override_value_order => 'is_virtual', :puppetclass => puppetclasses(:two))
    lookup_value = FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => RFauxFactory.gen_alpha, :match => 'is_virtual=true')
    get :show, params: { :id => lookup_key.id }
    assert_equal JSON.parse(response.body)['override_values_count'], 1
    lookup_value.destroy
    get :show, params: { :id => lookup_key.id }
    assert_equal JSON.parse(response.body)['override_values_count'], 0
  end

  test_attributes :pid => '73151830-e902-4b9e-888e-149570869530'
  test "should unhide default value" do
    value = RFauxFactory.gen_alpha
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :default_value => value, :hidden_value => true, :puppetclass => puppetclasses(:two))
    get :show, params: { :id => lookup_key.id }
    assert_equal JSON.parse(response.body)['hidden_value?'], true
    put :update, params: { :id => lookup_keys(:five).id, :smart_class_parameter => { :hidden_value => false } }
    assert_response :success
    assert_equal JSON.parse(response.body)['hidden_value?'], false
  end

  test_attributes :pid => '6f7ad3c4-7745-45bf-a9f9-697f049556da'
  test "update hidden value in parameter" do
    old_value = RFauxFactory.gen_alpha
    new_value = RFauxFactory.gen_alpha
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :default_value => old_value, :hidden_value => true, :puppetclass => puppetclasses(:two))
    get :show, params: { :id => lookup_key.id, :show_hidden => true }
    assert_equal JSON.parse(response.body)['hidden_value?'], true
    assert_equal JSON.parse(response.body)['default_value'], old_value
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :default_value => new_value } }
    get :show, params: { :id => lookup_key.id, :show_hidden => true }
    assert_equal JSON.parse(response.body)['hidden_value?'], true
    assert_equal JSON.parse(response.body)['default_value'], new_value
  end

  test_attributes :pid => '92977eb0-92c2-4734-84d9-6fda8ff9d2d8'
  test "validate default value requires check" do
    put :update, params: { :id => lookup_keys(:five).id, :smart_class_parameter => { :override => true, :required => true, :parameter_type => "boolean", :default_value => true } }
    get :show, params: { :id => lookup_keys(:five).id }
    assert_equal JSON.parse(response.body)['required'], true
    assert_equal JSON.parse(response.body)['default_value'], true
  end

  test_attributes :pid => 'd5d5f084-fa62-4ec3-90ea-9fcabd7bda4f'
  test "validate default value with list" do
    values_list = [RFauxFactory.gen_alpha, RFauxFactory.gen_alphanumeric, rand(100..1 << 64), [true, false].sample]
    values_list_str = values_list.join(", ")
    value = values_list.sample
    put :update, params: { :id => lookup_keys(:five).id, :smart_class_parameter => { :override => true, :default_value => value, :validator_type => "list", :validator_rule => values_list_str } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal value.to_s, response['default_value']
    assert_equal 'list', response['validator_type']
    assert_equal values_list_str, response['validator_rule']
  end

  test_attributes :pid => 'd5df7804-9633-4ef8-a065-10807351d230'
  test "validate default value with regexp" do
    value = rand(1..1 << 64)
    put :update, params: { :id => lookup_keys(:five).id, :smart_class_parameter => { :override => true, :default_value => value, :validator_type => "regexp", :validator_rule => '[0-9]' } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal value.to_s, response['default_value']
    assert_equal 'regexp', response['validator_type']
    assert_equal '[0-9]', response['validator_rule']
  end

  test_attributes :pid => 'bf620cef-c7ab-4a32-9050-bd06040dc8d1'
  test "should validate matcher required check" do
    value = RFauxFactory.gen_alpha
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :puppetclass => puppetclasses(:two))
    FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => value, :match => 'domain=example.com')
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :required => true } }
    get :show, params: { :id => lookup_key.id }
    assert_equal JSON.parse(@response.body)['required'], true
    assert_equal JSON.parse(@response.body)['override_values'][0]['value'], value
  end

  test_attributes :pid => '77b6e90d-e38a-4973-98e3-c698eae5c534'
  test "should validate matcher with default type" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :default_value => true, :parameter_type => 'boolean', :puppetclass => puppetclasses(:two))
    FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => false, :match => 'domain=example.com')
    get :show, params: { :id => lookup_key.id }
    assert_equal JSON.parse(@response.body)['override_values'][0]['match'], 'domain=example.com'
    assert_equal JSON.parse(@response.body)['override_values'][0]['value'], false
  end

  test_attributes :pid => '05c1a0bb-ba27-4842-bb6a-8420114cffe7'
  test "should validate matcher value with list" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :puppetclass => puppetclasses(:two))
    FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => 30, :match => 'domain=example.com')
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :default_value => "example", :validator_type => "list", :validator_rule => "test, example, 30" } }
    assert_equal JSON.parse(@response.body)['default_value'], "example"
  end

  test_attributes :pid => '74164406-885b-4f5b-8ea0-06738314310f'
  test "should validate matcher value with regexp" do
    value = RFauxFactory.gen_numeric_string
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :puppetclass => puppetclasses(:two))
    FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => RFauxFactory.gen_numeric_string, :match => 'domain=test.com')
    put :update, params: { :id => lookup_key.id, :smart_class_parameter => { :override => true, :default_value => value, :validator_type => "regexp", :validator_rule => "[0-9]" } }
    assert_equal JSON.parse(@response.body)['default_value'], value
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
      FactoryBot.create(:environment_class, :environment => environments(:testing), :puppetclass => puppetclasses(:one), :puppetclass_lookup_key => parameter)
      get :show, params: { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['default_value']
    end

    test "should show a smart class parameter unhidden when show_hidden is true" do
      parameter = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing), :puppetclass => puppetclasses(:one), :puppetclass_lookup_key => parameter)
      setup_user "view", "puppetclasses"
      setup_user "view", "external_parameters"
      setup_user "edit", "external_parameters"
      get :show, params: { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id, :show_hidden => 'true' }, session: set_session_user.merge(:user => users(:one).id)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.default_value, show_response['default_value']
    end

    test "should show a smart class parameter parameter as hidden when show_hidden is true if user is not authorized" do
      parameter = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing), :puppetclass => puppetclasses(:one), :puppetclass_lookup_key => parameter)
      setup_user "view", "puppetclasses"
      setup_user "view", "external_parameters"
      get :show, params: { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id, :show_hidden => 'true' }, session: set_session_user.merge(:user => users(:one).id)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['default_value']
    end

    test "should show a smart class parameter's overrides unhidden when show_hidden is true" do
      parameter = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing), :puppetclass => puppetclasses(:one), :puppetclass_lookup_key => parameter)
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
      FactoryBot.create(:environment_class, :environment => environments(:testing), :puppetclass => puppetclasses(:one), :puppetclass_lookup_key => parameter)
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
