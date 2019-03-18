require 'test_helper'

class Queries::OrganizationQueryTest < ActiveSupport::TestCase
  test 'fetching organization attributes' do
    organization = FactoryBot.create(:organization)

    query = <<-GRAPHQL
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

    organization_global_id = Foreman::GlobalId.for(organization)
    variables = { id: organization_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'organization' => {
        'id' => organization_global_id,
        'createdAt' => organization.created_at.utc.iso8601,
        'updatedAt' => organization.updated_at.utc.iso8601,
        'name' => organization.name,
        'title' => organization.title
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
