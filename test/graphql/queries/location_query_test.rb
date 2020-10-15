require 'test_helper'

module Queries
  class LocationQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        location(id: $id) {
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
          hosts {
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

    let(:hosts) { FactoryBot.create_list(:host, 2) }
    let(:location_object) { FactoryBot.create(:location, hosts: hosts) }

    let(:global_id) { Foreman::GlobalId.for(location_object) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['location'] }

    test 'fetching location attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal location_object.created_at.utc.iso8601, data['createdAt']
      assert_equal location_object.updated_at.utc.iso8601, data['updatedAt']
      assert_equal location_object.name, data['name']
      assert_equal location_object.title, data['title']

      assert_collection location_object.environments, data['environments']
      assert_collection location_object.hosts, data['hosts'], type_name: 'Host'
    end
  end
end
