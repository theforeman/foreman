require 'test_helper'

class Queries::DomainQueryTest < ActiveSupport::TestCase
  test 'fetching domain attributes' do
    domain = FactoryBot.create(:domain)

    query = <<-GRAPHQL
      query {
        domains(search: "name=#{domain.name}") {
          pageInfo {
            startCursor
            endCursor
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              id
              name
              fullname
            }
          }
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_domain_attributes = {
      'id' => domain.id,
      'name' => domain.name,
      'fullname' => domain.fullname
    }

    assert_includes result['data']['domains']['edges'].map { |e| e['node'] }, expected_domain_attributes
  end
end
