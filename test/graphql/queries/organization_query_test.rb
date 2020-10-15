require 'test_helper'

module Queries
  class OrganizationQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        organization(id: $id) {
          id
          createdAt
          updatedAt
          name
          title
        }
      }
      GRAPHQL
    end

    let(:organization) { FactoryBot.create(:organization) }

    let(:global_id) { Foreman::GlobalId.for(organization) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['organization'] }

    test 'fetching organization attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal organization.created_at.utc.iso8601, data['createdAt']
      assert_equal organization.updated_at.utc.iso8601, data['updatedAt']
      assert_equal organization.name, data['name']
      assert_equal organization.title, data['title']
    end
  end
end
