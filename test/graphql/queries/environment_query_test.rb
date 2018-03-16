require 'test_helper'

class Queries::EnvironmentQueryTest < ActiveSupport::TestCase
  test 'fetching environment attributes' do
    environment = environments(:testing)

    query = <<-GRAPHQL
      query {
        environment(id: #{environment.id}) {
          id
          name
          puppetclasses {
            edges {
              node {
                id
                name
              }
            }
          }
        }
      }
    GRAPHQL

    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: {}, context: context)

    expected_environment_attributes = {
      'id' => environment.id,
      'name' => environment.name,
      'puppetclasses' => {
        'edges' => environment.puppetclasses.map do |pc|
          {
            'node' => {
              'id' => pc.id,
              'name' => pc.name
            }
          }
        end
      }
    }

    assert_equal expected_environment_attributes, result['data']['environment']
  end
end
