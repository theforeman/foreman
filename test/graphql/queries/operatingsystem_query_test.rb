require 'test_helper'

class Queries::OperatingsystemQueryTest < GraphQLQueryTestCase
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
  let(:operatingsystem) { FactoryBot.create(:operatingsystem, hosts: hosts) }

  let(:global_id) { Foreman::GlobalId.for(operatingsystem) }
  let(:variables) {{ id: global_id }}
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

    assert_collection operatingsystem.hosts, data['hosts'], type_name: 'Host'
  end
end
