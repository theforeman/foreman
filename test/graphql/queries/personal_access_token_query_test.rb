require 'test_helper'

class Queries::PersonalAccessTokenQueryTest < ActiveSupport::TestCase
  test 'fetching personalAccessToken attributes' do
    personal_access_token = FactoryBot.create(:personal_access_token)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        personalAccessToken(id: $id) {
          id
          createdAt
          updatedAt
          name
          expiresAt
          lastUsedAt
          revoked
          expires
          active
          used
          user {
            id
          }
        }
      }
    GRAPHQL

    personal_access_token_global_id = Foreman::GlobalId.for(personal_access_token)
    variables = { id: personal_access_token_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected_personal_access_token_attributes = {
      'id' => personal_access_token_global_id,
      'createdAt' => personal_access_token.created_at.utc.iso8601,
      'updatedAt' => personal_access_token.updated_at.utc.iso8601,
      'name' => personal_access_token.name,
      'expiresAt' => personal_access_token.expires_at.utc.iso8601,
      'lastUsedAt' => nil,
      'revoked' => personal_access_token.revoked?,
      'expires' => personal_access_token.expires?,
      'active' => personal_access_token.active?,
      'used' => personal_access_token.used?,
      'user' => {
        'id' => Foreman::GlobalId.for(personal_access_token.user)
      }
    }

    assert_empty result['errors']
    assert_equal expected_personal_access_token_attributes, result['data']['personalAccessToken']
  end
end
