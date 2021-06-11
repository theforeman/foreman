require 'test_helper'

module Queries
  class LookupValueQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        lookupValue(id: $id) {
          id
          createdAt
          updatedAt
          match
          value
          omit
        }
      }
      GRAPHQL
    end

    let(:lookup_value) { FactoryBot.create(:lookup_value, :match => 'hostgroup=test_hostgroup') }
    let(:global_id) { Foreman::GlobalId.for(lookup_value) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['lookupValue'] }

    setup do
      FactoryBot.create(:hostgroup, :name => 'test_hostgroup')
    end

    test 'should fetch lookup value attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal lookup_value.created_at.utc.iso8601, data['createdAt']
      assert_equal lookup_value.updated_at.utc.iso8601, data['updatedAt']
      assert_equal lookup_value.value, data['value']
      assert_equal lookup_value.match, data['match']
      assert_equal lookup_value.omit, data['omit']
    end
  end
end
