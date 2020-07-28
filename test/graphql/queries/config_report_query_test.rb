require 'test_helper'

module Queries
  class ConfigReportQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
        query configReport($id: String!){
          configReport(id: $id) {
            id
            createdAt
            updatedAt
            metrics
            status
            origin
          }
        }
      GRAPHQL
    end

    let(:host) { FactoryBot.create(:host) }
    let(:report) { FactoryBot.create(:report, :host_id => host.id) }
    let(:global_id) { Foreman::GlobalId.for(report) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['configReport'] }

    test 'fetch config report by global id' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal report.metrics, data['metrics']
      assert_equal report.status, data['status']
      assert_equal report.origin, data['origin']
    end
  end
end
