require 'test_helper'

module Mutations
  module Settings
    class UpdateSettingTest < ActiveSupport::TestCase
      let(:setting) { settings(:attributes54) }
      let(:global_id) { Foreman::GlobalId.for(setting) }
      let(:new_value) { 'foo' }
      let(:variables) {{ id: global_id, value: new_value }}
      let(:query) do
        <<-GRAPHQL
          mutation updateSettingMutation($id: ID!, $value: String) {
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

      test "update a setting" do
        context = { current_user: FactoryBot.create(:user, :admin) }
        result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
        assert_empty result['errors']
        assert_empty result['data']['updateSetting']['errors']
        setting.reload
        assert_equal new_value, setting.value
      end
    end
  end
end
