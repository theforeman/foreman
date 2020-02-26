require 'test_helper'

module Queries
  class OperatingsystemQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        operatingsystem(id: $id) {
          id
          createdAt
          updatedAt
          name
          title
          type
          fullname
          family
          hosts {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          media {
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
    let(:medium) { FactoryBot.create(:medium) }
    let(:operatingsystem) { FactoryBot.create(:operatingsystem, family: 'Redhat', hosts: hosts, media: [medium]) }

    let(:global_id) { Foreman::GlobalId.for(operatingsystem) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['operatingsystem'] }

    test 'fetching operatingsystem attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal operatingsystem.created_at.utc.iso8601, data['createdAt']
      assert_equal operatingsystem.updated_at.utc.iso8601, data['updatedAt']
      assert_equal operatingsystem.name, data['name']
      assert_equal operatingsystem.title, data['title']
      assert_equal operatingsystem.type, data['type']
      assert_equal operatingsystem.fullname, data['fullname']
      assert_equal operatingsystem.family, data['family']

      assert_collection operatingsystem.hosts, data['hosts'], type_name: 'Host'
      assert_collection operatingsystem.media, data['media']
    end
  end
end
