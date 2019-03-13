require 'test_helper'

class Queries::ArchitectureQueryTest < ActiveSupport::TestCase
  test 'fetching architecture attributes' do
    architecture = FactoryBot.create(:architecture)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        architecture(id: $id) {
          id
          createdAt
          updatedAt
          name
        }
      }
    GRAPHQL

    architecture_global_id = Foreman::GlobalId.for(architecture)
    variables = { id: architecture_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'architecture' => {
        'id' => architecture_global_id,
        'createdAt' => architecture.created_at.utc.iso8601,
        'updatedAt' => architecture.updated_at.utc.iso8601,
        'name' => architecture.name
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
