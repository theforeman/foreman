require 'test_helper'

module Queries
  class SettingQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query($id: String!){
        setting(id: $id) {
          id
          name
          value
          default
          encrypted
          description
          fullName
          category
          settingsType
        }
      }
      GRAPHQL
    end

    let(:setting) { Setting.find_by :name => 'access_unattended_without_build' }
    let(:global_id) { Foreman::GlobalId.for(setting) }
    let(:variables) {{ id: global_id }}
    let(:data) { result['data']['setting'] }

    test 'fetching a setting' do
      assert_empty result['errors']
      assert_equal global_id, data['id']
      assert_equal setting.name, data['name']
      assert_equal setting.value.to_s, data['value']
      assert_equal setting.default.to_s, data['default']
      assert_equal setting.encrypted?, data['encrypted']
      assert_equal setting.full_name, data['fullName']
      assert_equal setting.category, data['category']
      assert_equal setting.settings_type, data['settingsType']
    end
  end
end
