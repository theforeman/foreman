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
          environments {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          puppetclasses {
            totalCount
            edges {
              node {
                id
              }
            }
          }
        }
      }
      GRAPHQL
    end

    let(:environment) { FactoryBot.create(:environment) }
    let(:organization) { FactoryBot.create(:organization, environments: [environment]) }

    let(:global_id) { Foreman::GlobalId.for(organization) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['organization'] }

    setup do
      FactoryBot.create(:puppetclass, :environments => [environment])
    end

    test 'fetching organization attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal organization.created_at.utc.iso8601, data['createdAt']
      assert_equal organization.updated_at.utc.iso8601, data['updatedAt']
      assert_equal organization.name, data['name']
      assert_equal organization.title, data['title']

      assert_collection organization.environments, data['environments']
      assert_collection organization.puppetclasses, data['puppetclasses']
    end
  end
end
