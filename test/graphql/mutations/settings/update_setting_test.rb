require 'test_helper'

module Mutations
  module Settings
    class UpdateSettingTest < ActiveSupport::TestCase
      let(:setting) { settings(:attributes54) }
      let(:global_id) { Foreman::GlobalId.for(setting) }
      let(:new_value) { 'foo' }
      let(:variables) { { id: global_id, value: new_value } }
      let(:admin_context) { { current_user: FactoryBot.create(:user, :admin) } }
      let(:query) do
        <<-GRAPHQL
          mutation updateSettingMutation($id: ID!, $value: String!) {
            updateSetting(input: { id: $id, value: $value }) {
              setting {
                id
                name
                value
              }
              errors {
                path
                message
              }
            }
          }
        GRAPHQL
      end

      test "should update a setting" do
        result = ForemanGraphqlSchema.execute(query, variables: variables, context: admin_context)
        assert_empty result['errors']
        assert_empty result['data']['updateSetting']['errors']
        setting.reload
        assert_equal new_value, setting.value
      end

      test "should require a value" do
        result = ForemanGraphqlSchema.execute(query, variables: { id: global_id }, context: admin_context)
        assert_not_empty result['errors']
        assert_equal "Variable value of type String! was provided invalid value", result['errors'].first['message']
      end

      test "should parse string values to integers" do
        setting = Setting.where(:settings_type => 'integer').first
        id = Foreman::GlobalId.for(setting)
        result = ForemanGraphqlSchema.execute(query, variables: { id: id, value: '42' }, context: admin_context)
        assert_empty result['errors']
        setting.reload
        assert_equal 42, setting.value
      end

      test "should parse string values to arrays" do
        setting = Setting.where(:settings_type => 'array').first
        id = Foreman::GlobalId.for(setting)
        result = ForemanGraphqlSchema.execute(query, variables: { id: id, value: "['192.168.100.1', '192.168.42.1']" }, context: admin_context)
        assert_empty result['errors']
        setting.reload
        assert_equal ['192.168.100.1', '192.168.42.1'], setting.value
      end

      test "should parse string values to booleans" do
        setting = Setting.where(:settings_type => 'boolean').first
        id = Foreman::GlobalId.for(setting)
        result = ForemanGraphqlSchema.execute(query, variables: { id: id, value: "true" }, context: admin_context)
        assert_empty result['errors']
        setting.reload
        assert_equal true, setting.value
      end
    end
  end
end
