require 'test_helper'

module Queries
  class RenderingStatusCombinationQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        renderingStatusCombination(id: $id) {
          id
          createdAt
          updatedAt
          safemodeStatus
          unsafemodeStatus
          host {
            id
          }
          template {
            id
          }
        }
      }
      GRAPHQL
    end

    let(:rendering_status_combination) { FactoryBot.create(:rendering_status_combination, :safemode_ok, :unsafemode_ok) }
    let(:global_id) { Foreman::GlobalId.for(rendering_status_combination) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['renderingStatusCombination'] }

    test 'fetching rendering status combination attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal rendering_status_combination.created_at.utc.iso8601, data['createdAt']
      assert_equal rendering_status_combination.updated_at.utc.iso8601, data['updatedAt']
      assert_equal rendering_status_combination.safemode_status, data['safemodeStatus']
      assert_equal rendering_status_combination.unsafemode_status, data['unsafemodeStatus']

      assert_record rendering_status_combination.host, data['host']
      assert_record rendering_status_combination.template, data['template']
    end
  end
end
