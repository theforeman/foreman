require 'test_helper'

module Queries
  class LookupValuesQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query {
        lookupValues {
          totalCount
          pageInfo {
            startCursor
            endCursor
            hasNextPage
            hasPreviousPage
          }
          edges {
            cursor
            node {
              id
              match
              value
            }
          }
        }
      }
      GRAPHQL
    end

    let(:data) { result['data']['lookupValues'] }

    setup do
      @parent = FactoryBot.create(:hostgroup, :name => 'parent_hostgroup')
      @child = FactoryBot.create(:hostgroup, :name => 'test_hostgroup', :parent => @parent)
      FactoryBot.create(:lookup_value, :match => "hostgroup=#{@child.title}")
      FactoryBot.create(:lookup_value, :match => "hostgroup=#{@parent.title}")
    end

    test 'should fetch lookup values attributes' do
      assert_empty result['errors']

      expected_count = ::LookupValue.count

      assert_not_equal 0, expected_count
      assert_equal expected_count, data['totalCount']
      assert_equal expected_count, data['edges'].count
      [@child.title, @parent.title].each do |title|
        assert data['edges'].find { |edge| edge['node']['match'] == "hostgroup=#{title}" }
      end
    end
  end
end
