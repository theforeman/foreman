require 'test_helper'

module Queries
  class ProvisioningTemplateQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        provisioningTemplate(id: $id) {
          id
          createdAt
          updatedAt
          name
        }
      }
      GRAPHQL
    end

    let(:provisioning_template) { FactoryBot.create(:provisioning_template) }
    let(:global_id) { Foreman::GlobalId.for(provisioning_template) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['provisioningTemplate'] }

    test 'fetching provisioning template attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal provisioning_template.created_at.utc.iso8601, data['createdAt']
      assert_equal provisioning_template.updated_at.utc.iso8601, data['updatedAt']
      assert_equal provisioning_template.name, data['name']
    end
  end
end
