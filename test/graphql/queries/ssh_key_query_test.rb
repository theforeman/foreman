require 'test_helper'

module Queries
  class SshKeyQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        sshKey(id: $id) {
          id
          createdAt
          updatedAt
          name
          key
          fingerprint
          length
          comment
          exportableKey
          user {
            id
          }
        }
      }
      GRAPHQL
    end

    let(:ssh_key) { FactoryBot.create(:ssh_key) }

    let(:global_id) { Foreman::GlobalId.for(ssh_key) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['sshKey'] }

    test 'fetching ssh_key attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal ssh_key.created_at.utc.iso8601, data['createdAt']
      assert_equal ssh_key.updated_at.utc.iso8601, data['updatedAt']
      assert_equal ssh_key.name, data['name']
      assert_equal ssh_key.key, data['key']
      assert_equal ssh_key.fingerprint, data['fingerprint']
      assert_equal ssh_key.length, data['length']
      assert_equal ssh_key.comment, data['comment']
      assert_equal ssh_key.to_export, data['exportableKey']

      assert_record ssh_key.user, data['user']
    end
  end
end
