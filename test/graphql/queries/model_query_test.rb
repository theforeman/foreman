require 'test_helper'

module Queries
  class ModelQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        model(id: $id) {
          id
          createdAt
          updatedAt
          name
          info
          vendorClass
          hardwareModel
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

    let(:host) { as_admin { FactoryBot.create(:host, :with_model) } }
    let(:model) { host.model }

    let(:global_id) { Foreman::GlobalId.for(model) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['model'] }

    setup do
      # Create a host that is not associated to the model
      # so we can test it does not show up in the result
      FactoryBot.create(:host, :managed)
    end

    test 'fetching model attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal model.created_at.utc.iso8601, data['createdAt']
      assert_equal model.updated_at.utc.iso8601, data['updatedAt']
      assert_equal model.name, data['name']
      assert_equal model.info, data['info']
      assert_equal model.vendor_class, data['vendorClass']
      assert_equal model.hardware_model, data['hardwareModel']

      assert_collection model.hosts, data['hosts'], type_name: 'Host'
    end

    context 'with user without view_hosts permission' do
      let(:context_user) { setup_user 'view', 'models' }

      test 'does not load associated hosts' do
        assert_empty result['errors']

        assert_equal 0, data['hosts']['totalCount']
        assert_empty data['hosts']['edges']
      end
    end
  end
end
