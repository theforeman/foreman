require 'test_helper'

module Queries
  class RenderingStatusQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        renderingStatus(id: $id) {
          id
          status
          safemodeStatus
          unsafemodeStatus
          label
          host {
            id
          }
          combinations {
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

    let(:rendering_status_combination) { FactoryBot.create(:rendering_status_combination, :safemode_ok) }
    let(:rendering_status) { rendering_status_combination.host.rendering_status }

    let(:global_id) { Foreman::GlobalId.for(rendering_status) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['renderingStatus'] }

    test 'fetching rendering status attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal rendering_status.status, data['status']
      assert_equal rendering_status.safemode_status, data['safemodeStatus']
      assert_equal rendering_status.unsafemode_status, data['unsafemodeStatus']
      assert_equal rendering_status.to_label, data['label']

      assert_record rendering_status.host, data['host']
      assert_collection rendering_status.combinations, data['combinations']
    end
  end
end
