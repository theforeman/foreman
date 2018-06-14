require 'test_helper'

class Api::V2::SmartVariablesControllerTest < ActionController::TestCase
  should use_before_action(:cast_default_value)

  test "should get all smart variables" do
    get :index
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 3, results['results'].length
  end

  test "should get smart variables for a specific host" do
    @host = FactoryBot.create(:host,
                               :puppetclasses => [puppetclasses(:one)],
                               :environment => environments(:production))
    get :index, params: { :host_id => @host.to_param }
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 2, results['results'].count
    assert_equal "bool_test", results['results'][0]['variable']
  end

  test "should get smart variables for a specific hostgroup" do
    get :index, params: { :hostgroup_id => hostgroups(:common).to_param }
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 2, results['results'].count
    assert_equal "bool_test", results['results'][0]['variable']
  end

  test_attributes :pid => 'cd743329-b354-4ddc-ada0-3ddd774e2701'
  test "should get smart variables for a specific puppetclass" do
    get :index, params: { :puppetclass_id => puppetclasses(:two).id }
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    refute results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "special_info", results['results'][0]['variable']
  end

  test_attributes :pid => '4cd20cca-d419-43f5-9734-e9ae1caae4cb'
  test "should create a smart variable" do
    variable_name = 'test_smart_variable'
    puppetclass_id = puppetclasses(:one).id
    assert_difference('LookupKey.count') do
      as_admin do
        valid_attrs = { :variable => variable_name, :puppetclass_id => puppetclass_id }
        post :create, params: { :smart_variable => valid_attrs }
      end
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('variable')
    assert_equal response['puppetclass_id'], puppetclass_id
  end

  test_attributes :pid => 'd92f8bdd-93de-49ba-85a3-685aac9eda0a'
  test "should not create a smart variable" do
    assert_difference('LookupKey.count', 0) do
      as_admin do
        post :create, params: { :smart_variable => { :variable => '', :puppetclass_id => puppetclasses(:one).id } }
      end
    end
    assert_response :unprocessable_entity
  end

  test "should show specific smart variable" do
    get :show, params: { :id => lookup_keys(:two).to_param, :puppetclass_id => puppetclasses(:one).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update smart variable default value" do
    orig_value = lookup_keys(:four).default_value
    put :update, params: { :id => lookup_keys(:four).to_param, :smart_variable => { :default_value => 'newstring' } }
    assert_response :success
    new_value = lookup_keys(:four).reload.default_value
    refute_equal orig_value, new_value
  end

  test_attributes :pid => '2312cb28-c3b0-4fbc-84cf-b66f0c0c64f0'
  test "should update smart variable puppet class" do
    smart_variable = lookup_keys(:four)
    new_puppet_class_id = puppetclasses(:one).id
    refute_equal smart_variable.puppetclass_id, new_puppet_class_id
    put :update, params: { :id => smart_variable.to_param, :smart_variable => { :puppetclass_id => new_puppet_class_id } }
    assert_response :success
    smart_variable.reload
    assert_equal new_puppet_class_id, smart_variable.puppetclass_id
  end

  test_attributes :pid => 'b8214eaa-e276-4fc4-8381-fb0386cda6a5'
  test "should update smart variable name" do
    smart_variable = lookup_keys(:four)
    new_variable_name = 'four_new_variable_name'
    refute_equal new_variable_name, smart_variable.variable
    put :update, params: { :id => smart_variable.to_param, :smart_variable => { :variable => new_variable_name } }
    assert_response :success
    smart_variable.reload
    assert_equal new_variable_name, smart_variable.variable
  end

  test_attributes :pid => '6d8354db-a028-4ae0-bcb6-87aa1cb9ec5d'
  test "should destroy smart variable" do
    assert_difference('LookupKey.count', -1) do
      delete :destroy, params: { :id => lookup_keys(:four).to_param }
    end
    assert_response :success
  end

  test_attributes :pid => 'c49ad14d-913f-4adc-8ebf-88493556c027'
  test "should not duplicate smart variable" do
    assert_difference('LookupKey.count', 0) do
      as_admin do
        post :create, params: { :smart_variable => {
          :variable => lookup_keys(:four).variable,
          :puppetclass_id => puppetclasses(:two).id
        }}
      end
    end
    assert_response :unprocessable_entity
    assert_include @response.body, 'Key has already been taken'
  end

  test_attributes :pid => '4c8b4134-33c1-4f7f-83f9-a751c49ae2da'
  test "should create smart variable with valid type and default_value" do
    valid_attr = {
      :variable => 'new_variable_name',
      :puppetclass_id => puppetclasses(:two).id,
      :variable_type => 'array',
      :default_value => '["a string", "123456789", "<test>html</test>"]'
    }
    assert_difference('LookupKey.count') do
      as_admin do
        post :create, params: { :smart_variable => valid_attr }
      end
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('variable_type')
    assert_equal valid_attr[:variable_type], response['variable_type']
    assert response.key?('default_value')
    assert_equal JSON.parse(valid_attr[:default_value]), response['default_value']
  end

  test_attributes :pid => '9709d67c-682f-4e6c-8b8b-f02f6c2d3b71'
  test "should not create smart variable with invalid default_value" do
    invalid_attr = {
      :variable => 'new_variable_name',
      :puppetclass_id => puppetclasses(:two).id,
      :variable_type => 'array',
      :default_value => 'not a valid array in a string'
    }
    assert_difference('LookupKey.count', 0) do
      as_admin do
        post :create, params: { :smart_variable => invalid_attr }
      end
    end
    assert_response :unprocessable_entity
    assert_include @response.body, 'Default value is invalid'
  end

  test_attributes :pid => 'aa9803b9-9a45-4ad8-b502-e0e32fc4b7d8'
  test "should update smart variable with default value that match regexp validator" do
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :default_value => RFauxFactory.gen_alpha
    )
    valid_attr = { :validator_type => 'regexp', :validator_rule => '[0-9]', :default_value => RFauxFactory.gen_numeric_string }
    put :update, params: { :id => smart_variable.to_param, :smart_variable => valid_attr }
    assert_response :success
    smart_variable.reload
    assert_equal valid_attr[:default_value], smart_variable.default_value
    assert_equal valid_attr[:validator_type], smart_variable.validator_type
    assert_equal valid_attr[:validator_rule], smart_variable.validator_rule
  end

  test_attributes :pid => '0c80bd58-26aa-4c2a-a087-ed3b88b226a7'
  test "should not update smart variable with default value that do not match regexp validator" do
    default_value = RFauxFactory.gen_alpha
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :default_value => default_value
    )
    put :update, params: { :id => smart_variable.to_param, :smart_variable => {
      :validator_type => 'regexp',
      :validator_rule => '[0-9]',
      :default_value => RFauxFactory.gen_alpha
    }}
    assert_response :error
    assert_include @response.body, 'Validation failed: Default value is invalid'
    smart_variable.reload
    assert_equal default_value, smart_variable.default_value
  end

  test_attributes :pid => '6bc2caa0-1300-4751-8239-34b96517465b'
  test "should create smart variable with default value that match list validator rule" do
    values_list = [
      RFauxFactory.gen_alpha,
      RFauxFactory.gen_alphanumeric,
      rand(100..1000000),
      %w[true false].sample
    ]
    validator_rule = values_list.join(', ')
    default_value = values_list[1]
    assert_difference('LookupKey.count') do
      as_admin do
        post :create, params: { :smart_variable => {
          :variable => RFauxFactory.gen_alpha,
          :puppetclass_id => puppetclasses(:two).id,
          :validator_type => 'list',
          :validator_rule => validator_rule,
          :default_value => default_value
        }}
      end
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('default_value')
    assert_equal default_value, response['default_value']
    assert response.key?('validator_type')
    assert_equal 'list', response['validator_type']
    assert response.key?('validator_type')
    assert_equal validator_rule, response['validator_rule']
  end

  test_attributes :pid => 'cacb83a5-3e50-490b-b94f-a5d27f44ae12'
  test "should not create smart variable with default value that do not match list validator rule" do
    validator_rule = '5, test'
    default_value = 'example'
    assert_difference('LookupKey.count', 0) do
      as_admin do
        post :create, params: { :smart_variable => {
          :variable => RFauxFactory.gen_alpha,
          :puppetclass_id => puppetclasses(:two).id,
          :validator_type => 'list',
          :validator_rule => validator_rule,
          :default_value => default_value
        }}
      end
    end
    assert_response :unprocessable_entity
    assert_include @response.body, "Default value #{default_value} is not one of #{validator_rule}"
  end

  test_attributes :pid => 'af2c16e1-9a78-4615-9bc3-34fadca6a179'
  test "should enable smart variable merge_overrides and merge_default flags" do
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :variable_type => 'array',
      :default_value => [rand(1..100000)]
    )
    refute smart_variable.merge_overrides
    refute smart_variable.merge_default
    put :update, params: { :id => smart_variable.to_param, :smart_variable => {
      :merge_overrides => true,
      :merge_default => true
    }}
    assert_response :success
    smart_variable.reload
    assert smart_variable.merge_overrides
    assert smart_variable.merge_default
  end

  test_attributes :pid => 'f62a7e23-6fb4-469a-8589-4c987ff589ef'
  test "should not enable smart variable merge_overrides flag" do
    smart_variable = lookup_keys(:four)
    refute_includes %w[array hash], smart_variable.variable_type
    put :update, params: { :id => smart_variable.to_param, :smart_variable => {
      :merge_overrides => true
    }}
    assert_response :error
    assert_includes @response.body, 'Validation failed: Merge overrides can only be set for array or hash'
  end

  test_attributes :pid => 'f5d2d032-2f72-4637-af61-90a556c42425'
  test "should not enable smart variable merge_default flag" do
    smart_variable = lookup_keys(:four)
    refute smart_variable.merge_overrides
    put :update, params: { :id => smart_variable.to_param, :smart_variable => {
      :merge_default => true
    }}
    assert_response :error
    assert_includes @response.body, 'Validation failed: Merge default can only be set when merge overrides is set'
  end

  test_attributes :pid => '98fb1884-ad2b-45a0-b376-66bbc5ef6f72'
  test "should enable smart variable avoid_duplicates flag" do
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :variable_type => 'array',
      :default_value => [rand(1..100000)]
    )
    refute smart_variable.merge_overrides
    refute smart_variable.avoid_duplicates
    put :update, params: { :id => smart_variable.to_param, :smart_variable => {
      :merge_overrides => true,
      :avoid_duplicates => true
    }}
    assert_response :success
    smart_variable.reload
    assert smart_variable.merge_overrides
    assert smart_variable.avoid_duplicates
  end

  test_attributes :pid => 'c7a2f718-6346-4851-b5f1-ab36c2fa8c6a'
  test "should not enable smart variable avoid_duplicates flag" do
    smart_variable = lookup_keys(:four)
    refute smart_variable.merge_overrides
    put :update, params: { :id => smart_variable.to_param, :smart_variable => {
      :avoid_duplicates => true
    }}
    assert_response :error
    assert_includes @response.body, 'Avoid duplicates can only be set for arrays that have merge_overrides set to true'
  end

  context 'hidden' do
    test_attributes :pid => '04bed7fa8-a5be-4fc0-8e9b-d68da00f8de0'
    test "should hide smart variable default_value" do
      assert_difference('LookupKey.count') do
        as_admin do
          post :create, params: { :smart_variable => {
            :variable => RFauxFactory.gen_alpha,
            :puppetclass_id => puppetclasses(:two).id,
            :hidden_value => true
          }}
        end
      end
      assert_response :created
      response = JSON.parse(@response.body)
      assert response.key?('hidden_value?')
      assert response['hidden_value?']
      assert response.key?('default_value')
      assert_equal '*****', response['default_value']
    end

    test_attributes :pid => 'e8b3ec03-1abb-48d8-9409-17178bb887cb'
    test "should unhide smart variable default_value" do
      smart_variable = FactoryBot.create(
        :variable_lookup_key,
        :variable => RFauxFactory.gen_alpha,
        :puppetclass_id => puppetclasses(:one).id,
        :hidden_value => true
      )
      assert smart_variable.hidden_value?
      put :update, params: { :id => smart_variable.to_param, :smart_variable => { :hidden_value => false } }
      assert_response :success
      smart_variable.reload
      refute smart_variable.hidden_value?
    end

    test_attributes :pid => '21b5586e-9434-45ea-ae85-12e24c549412'
    test "should update smart variable hidden_value" do
      smart_variable = FactoryBot.create(
        :variable_lookup_key,
        :variable => RFauxFactory.gen_alpha,
        :puppetclass_id => puppetclasses(:one).id,
        :hidden_value => true
      )
      assert smart_variable.hidden_value?
      default_value = RFauxFactory.gen_alpha
      put :update, params: { :id => smart_variable.to_param, :smart_variable => { :default_value => default_value } }
      assert_response :success
      smart_variable.reload
      assert smart_variable.hidden_value?
      assert_equal default_value, smart_variable.default_value
    end

    test "should show a smart variable as hidden unless show_hidden is true" do
      parameter = FactoryBot.create(:variable_lookup_key, :hidden_value => true, :default_value => 'hidden', :puppetclass => puppetclasses(:one))
      get :show, params: { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['default_value']
    end

    test "should show a smart variable unhidden when show_hidden is true" do
      parameter = FactoryBot.create(:variable_lookup_key, :hidden_value => true, :default_value => 'hidden', :puppetclass => puppetclasses(:one))
      setup_user "view", "puppetclasses"
      setup_user "view", "external_variables"
      setup_user "edit", "external_variables"
      get :show, params: { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id, :show_hidden => 'true' }, session: set_session_user.merge(:user => users(:one).id)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.default_value, show_response['default_value']
    end

    test "should show a smart variable parameter as hidden even when show_hidden is true if user is not authorized" do
      parameter = FactoryBot.create(:variable_lookup_key, :hidden_value => true, :default_value => 'hidden', :puppetclass => puppetclasses(:one))
      setup_user "view", "puppetclasses"
      setup_user "view", "external_variables"
      get :show, params: { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id, :show_hidden => 'true' }, session: set_session_user.merge(:user => users(:one).id)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['default_value']
    end
  end
end
