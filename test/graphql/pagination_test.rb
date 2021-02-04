require 'test_helper'

module Queries
  class PaginationTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query($pagination: PaginationInput) {
        models(pagination: $pagination) {
          totalCount
          recordsCount
          nodes {
            id
          }
        }
      }
      GRAPHQL
    end

    let(:variables) { { pagination: { page: 2, perPage: 5 } } }
    let(:data) { result['data']['models'] }

    setup do
      FactoryBot.create_list(:model, 20)
    end

    test 'fetching models attributes' do
      assert_empty result['errors']

      expected_count = Model.count

      assert_not_equal 0, expected_count
      assert_equal variables[:pagination][:perPage], data['totalCount']
      assert_equal expected_count, data['recordsCount']
      assert_equal variables[:pagination][:perPage], data['nodes'].count
      refute_includes data['nodes'].pluck('id'), Foreman::GlobalId.for(Model.first)
      refute_includes data['nodes'].pluck('id'), Foreman::GlobalId.for(Model.last)
    end
  end
end
