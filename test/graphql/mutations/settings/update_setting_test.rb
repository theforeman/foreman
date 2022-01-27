require 'test_helper'

module Mutations
  module Settings
    class UpdateSettingTest < GraphQLQueryTestCase
      let(:setting) { Foreman.settings.find('administrator') }
      let(:global_id) { Foreman::GlobalId.for(setting) }
      let(:new_value) { 'foo@example.com' }
      let(:variables) { { id: global_id, value: new_value } }
      let(:query) do
        <<-GRAPHQL
          mutation updateSettingMutation($id: ID!, $value: String!) {
            updateSetting(input: { id: $id, value: $value }) {
              setting {
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

      test "should update a setting by its GlobalId" do
        assert_empty result['errors']
        assert_empty result['data']['updateSetting']['errors']
        assert_equal new_value, setting.value
      end

      context 'with name param' do
        let(:variables) { { name: 'administrator', value: new_value } }
        let(:query) do
          <<-GRAPHQL
            mutation updateSettingMutation($name: String!, $value: String!) {
              updateSetting(input: { name: $name, value: $value }) {
                setting {
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

        test "should update a setting by its name" do
          assert_empty result['errors']
          assert_empty result['data']['updateSetting']['errors']
          assert_equal new_value, setting.value
        end
      end

      context 'without value' do
        let(:variables) { { id: global_id } }

        test "should require a value" do
          assert_not_empty result['errors']
          assert_equal "Variable value of type String! was provided invalid value", result['errors'].first['message']
        end
      end

      describe 'parsing' do
        context 'integers' do
          let(:setting) { Foreman.settings.detect { |set| set.settings_type == 'integer' } }
          let(:new_value) { '42' }

          test "should parse string values to integers" do
            assert_empty result['errors']
            assert_equal 42, setting.value
          end
        end

        context 'arrays' do
          let(:setting) { Foreman.settings.detect { |set| set.settings_type == 'array' } }
          let(:new_value) { "['192.168.100.1', '192.168.42.1']" }

          test "should parse string values to arrays" do
            assert_empty result['errors']
            assert_equal ['192.168.100.1', '192.168.42.1'], setting.value
          end
        end

        context 'boolean' do
          let(:setting) { Foreman.settings.detect { |set| set.settings_type == 'boolean' } }
          let(:new_value) { "true" }

          test "should parse string values to booleans" do
            assert_empty result['errors']
            assert_equal true, setting.value
          end
        end
      end
    end
  end
end
