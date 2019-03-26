require 'test_helper'

class Queries::PuppetclassQueryTest < ActiveSupport::TestCase
  test 'fetching puppetclass attributes' do
    environments = FactoryBot.create_list(:environment, 2)
    puppetclass = FactoryBot.create(:puppetclass, environments: environments)

    query = <<-GRAPHQL
      query (
        $id: String!
      ) {
        puppetclass(id: $id) {
          id
          createdAt
          updatedAt
          name
          environments {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          locations {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          organizations {
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

    puppetclass_global_id = Foreman::GlobalId.for(puppetclass)
    variables = { id: puppetclass_global_id }
    context = { current_user: FactoryBot.create(:user, :admin) }

    result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
    expected = {
      'puppetclass' => {
        'id' => puppetclass_global_id,
        'createdAt' => puppetclass.created_at.utc.iso8601,
        'updatedAt' => puppetclass.updated_at.utc.iso8601,
        'name' => puppetclass.name,
        'environments' => {
          'totalCount' => puppetclass.environments.count,
          'edges' => puppetclass.environments.sort_by(&:id).map do |environment|
            {
              'node' => {
                'id' => Foreman::GlobalId.for(environment)
              }
            }
          end
        },
        'locations' => {
          'totalCount' => puppetclass.locations.count,
          'edges' => puppetclass.locations.sort_by(&:id).map do |location|
            {
              'node' => {
                'id' => Foreman::GlobalId.for(location)
              }
            }
          end
        },
        'organizations' => {
          'totalCount' => puppetclass.organizations.count,
          'edges' => puppetclass.organizations.sort_by(&:id).map do |organization|
            {
              'node' => {
                'id' => Foreman::GlobalId.for(organization)
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
