require 'test_helper'

module Queries
  class ComputeAttributeQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        computeAttribute(id: $id) {
          id
          createdAt
          updatedAt
          name
          computeResource {
            id
          }
        }
      }
      GRAPHQL
    end

    let(:compute_resource) { FactoryBot.create(:compute_resource, :vmware, uuid: 'Solutions') }
    let(:compute_attribute) { compute_resource.compute_attributes.first }

    let(:global_id) { Foreman::GlobalId.for(compute_attribute) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['computeAttribute'] }

    setup do
      FactoryBot.create(:compute_profile, :with_compute_attribute, compute_resource: compute_resource)
    end

    test 'fetching compute attribute attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal compute_attribute.created_at.utc.iso8601, data['createdAt']
      assert_equal compute_attribute.updated_at.utc.iso8601, data['updatedAt']
      assert_equal compute_attribute.name, data['name']

      assert_record compute_attribute.compute_resource, data['computeResource']
    end
  end
end
