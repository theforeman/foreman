require 'test_helper'

class LookupKeysControllerTest < ActionController::TestCase
  tests PuppetclassLookupKeysController

  setup do
    @key = lookup_keys(:one)
    @base = {
      :key => @key.key,
      :override => true,
      :lookup_values_attributes => {}
    }
    @value = @key.override_values[1]
    @key.override_values = [@value]
    @create = {"1462788609698"=>{"match"=>"hostgroup=db", "value"=>'4', "omit"=>"0", "_destroy"=>"false"}}
    @delete = {"0"=>{"match"=>@value.match, "value"=>@value.value, "omit"=>"0", "_destroy"=>"1", "id"=>@value.id } }
  end

  test 'patch add valid override' do
    @key.override_values = []
    Setting::General.any_instance.stubs(:valid?).returns(true)

    assert_equal @key.override_values.count, 0
    params = @base.merge(:lookup_values_attributes => @create)
    patch :update, params: { :id => "#{@key.id}-#{@key.key}", :puppetclass_lookup_key => params }, session: set_session_user
    assert_redirected_to puppetclass_lookup_keys_path

    assert_equal @key.reload.override_values.count, 1
    value = @key.override_values.first
    assert_equal 'hostgroup=db', value.match
    assert_equal 4, value.value
  end

  test 'patch delete' do
    params = @base.merge(:lookup_values_attributes => @delete)
    patch :update, params: { :id => "#{@key.id}-#{@key.key}", :puppetclass_lookup_key => params }, session: set_session_user
    assert_redirected_to puppetclass_lookup_keys_path
    assert_equal 0, @key.reload.override_values.count
  end

  test 'patch add and delete' do
    params = @base.merge(:lookup_values_attributes => @create.merge(@delete))
    patch :update, params: { :id => "#{@key.id}-#{@key.key}", :puppetclass_lookup_key => params }, session: set_session_user
    assert_redirected_to puppetclass_lookup_keys_path
    assert_equal @key.reload.override_values.count, 1
    updated = @key.override_values.first
    assert_equal 4, updated.value
    assert_equal @value.match, updated.match
  end

  test 'patch conflicting' do
    create = {'1462788609699' => @create.values.first }
    params = @base.merge(:lookup_values_attributes => @create.merge(@delete.merge(create)))
    patch :update, params: { :id => "#{@key.id}-#{@key.key}", :puppetclass_lookup_key => params }, session: set_session_user
    assert_response :success
    assert_equal 1, @key.reload.override_values.count
    assert_equal @value.value, @key.override_values.first.value
  end
end
