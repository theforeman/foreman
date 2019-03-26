require 'test_helper'

class Queries::LocationQueryTest < ActiveSupport::TestCase
  test 'fetching location attributes' do
    environment = FactoryBot.create(:environment)
    FactoryBot.create(:puppetclass, :environments => [environment])
    location = FactoryBot.create(:location, environments: [environment])

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        location(id: $id) {
          id
          createdAt
          updatedAt
          name
          title
          environments {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          puppetclasses {
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

    location_global_id = Foreman::GlobalId.for(location)
    variables = { id: location_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'location' => {
        'id' => location_global_id,
        'createdAt' => location.created_at.utc.iso8601,
        'updatedAt' => location.updated_at.utc.iso8601,
        'name' => location.name,
        'title' => location.title,
        'environments' => {
          'totalCount' => location.environments.count,
          'edges' => location.environments.sort_by(&:id).map do |env|
            {
              'node' => {
                'id' => Foreman::GlobalId.for(env)
              }
            }
          end
        },
        'puppetclasses' => {
          'totalCount' => location.puppetclasses.count,
          'edges' => location.puppetclasses.sort_by(&:id).map do |puppetclass|
            {
              'node' => {
                'id' => Foreman::GlobalId.for(puppetclass)
              }
            }
          end
        }
      }
    }

    assert_empty result['errors']
    assert_equal expected, result['data']
  end
end
