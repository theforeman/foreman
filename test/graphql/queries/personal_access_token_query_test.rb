require 'test_helper'

module Queries
  class PersonalAccessTokenQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
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
    end

    let(:personal_access_token) { FactoryBot.create(:personal_access_token) }

    let(:global_id) { Foreman::GlobalId.for(personal_access_token) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['personalAccessToken'] }

    test 'fetching personalAccessToken attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal personal_access_token.created_at.utc.iso8601, data['createdAt']
      assert_equal personal_access_token.updated_at.utc.iso8601, data['updatedAt']
      assert_equal personal_access_token.name, data['name']
      assert_equal personal_access_token.expires_at.utc.iso8601, data['expiresAt']
      assert_equal nil, data['lastUsedAt']
      assert_equal personal_access_token.revoked?, data['revoked']
      assert_equal personal_access_token.expires?, data['expires']
      assert_equal personal_access_token.active?, data['active']
      assert_equal personal_access_token.used?, data['used']

      assert_record personal_access_token.user, data['user']
    end
  end
end
