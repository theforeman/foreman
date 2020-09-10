require 'test_helper'

module Mutations
  module Media
    class CreateMutationTest < ActiveSupport::TestCase
      let(:os_id) { Foreman::GlobalId.for(FactoryBot.create(:operatingsystem)) }
      let(:org_id) { Foreman::GlobalId.for(FactoryBot.create(:organization)) }
      let(:loc_id) { Foreman::GlobalId.for(FactoryBot.create(:location)) }
      let(:variables) do
        {
          name: 'My golden medium',
          path: 'https://my-medium.net',
          osFamily: 'Redhat',
          operatingsystemIds: [os_id],
          organizationIds: [org_id],
          locationIds: [loc_id],
        }
      end
      let(:query) do
        <<-GRAPHQL
          mutation createMediumMutation(
              $name: String!,
              $path: String!,
              $osFamily: OsFamilyEnum,
              $operatingsystemIds: [ID!],
              $organizationIds: [ID!],
              $locationIds: [ID!]
            ) {
            createMedium(input: {
              name: $name,
              path: $path,
              osFamily: $osFamily,
              operatingsystemIds: $operatingsystemIds,
              organizationIds: $organizationIds,
              locationIds: $locationIds
            }) {
              medium {
                id
                path
                osFamily
                operatingsystems {
                  nodes {
                    name
                  }
                }
                organizations {
                  nodes {
                    name
                  }
                }
                locations {
                  nodes {
                    name
                  }
                }
              }
              errors {
                path
                message
              }
            }
          }
        GRAPHQL
      end

      context 'with admin user' do
        let(:user) { FactoryBot.create(:user, :admin) }
        let(:context) { { current_user: user } }

        test 'create a medium' do
          assert_difference('Medium.count', +1) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_empty result['errors']
            assert_empty result['data']['createMedium']['errors']
          end
          assert_equal user.id, Audit.last.user_id
        end

        test 'should not create a medium twice' do
          assert_difference('Medium.count', +1) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_empty result['errors']
            assert_empty result['data']['createMedium']['errors']
          end

          assert_difference('Medium.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_includes result['data']['createMedium']['errors'], { "path" => ["attributes", "name"], "message" => "has already been taken" }
          end
        end
      end

      context 'with user with view permissions' do
        setup do
          variables
          @user = setup_user 'view', 'media'
        end

        test 'cannot create a medium' do
          context = { current_user: @user }
          assert_difference('::Medium.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_not_empty result['errors']
          end
        end
      end
    end
  end
end
