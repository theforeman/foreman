require 'test_helper'

module Mutations
  module Operatingsystems
    class CreateMutationTest < ActiveSupport::TestCase
      let(:variables) do
        {
          :name => 'my-os',
          :description => 'os description',
          :major => '15',
          :minor => '5',
          :releaseName => 'penguin',
          :family => 'Redhat',
          :passwordHash => 'SHA512',
          :mediumIds => [Foreman::GlobalId.for(FactoryBot.create(:medium))],
          :architectureIds => [Foreman::GlobalId.for(FactoryBot.create(:architecture))],
          :ptableIds => [Foreman::GlobalId.for(FactoryBot.create(:ptable))],
        }
      end
      let(:query) do
        <<-GRAPHQL
          mutation CreateOperatingsystemMutation(
            $name: String!,
            $description: String,
            $major:String,
            $minor: String,
            $releaseName: String,
            $family: OsFamilyEnum,
            $passwordHash: PasswordHashEnum,
            $architectureIds:[ID!],
            $mediumIds:[ID!],
            $ptableIds: [ID!]) {
              createOperatingsystem(
                input:{
                  name: $name,
                  description: $description,
                  major: $major,
                  minor: $minor,
                  releaseName: $releaseName,
                  family: $family,
                  passwordHash: $passwordHash,
                  architectureIds: $architectureIds,
                  mediumIds: $mediumIds,
                  ptableIds: $ptableIds,
                }
              ) {
                operatingsystem {
                  id
                  name
                  description
                  major
                  minor
                  family
                  architectures {
                    nodes {
                      name
                    }
                  }
                  ptables {
                    nodes {
                      name
                    }
                  }
                  media {
                    nodes {
                      name
                    }
                  }
                }
              }
          }
        GRAPHQL
      end

      context 'with admin user' do
        let(:user) { FactoryBot.create(:user, :admin) }

        test 'create an operating system' do
          context = { current_user: user }

          assert_difference('Operatingsystem.count', +1) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_empty result['errors']
            res = result['data']['createOperatingsystem']
            assert_empty res['errors']
            assert_not_empty res['operatingsystem']['architectures']['nodes']
            assert_not_empty res['operatingsystem']['ptables']['nodes']
            assert_not_empty res['operatingsystem']['media']['nodes']
          end
          assert_equal user.id, Audit.last.user_id
        end
      end

      context 'with user with view permissions' do
        setup do
          variables
          @user = setup_user 'view', 'operatingsystems'
        end

        test 'cannot create an operating system' do
          context = { current_user: @user }

          assert_difference('::Operatingsystem.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_not_empty result['errors']
          end
        end
      end
    end
  end
end
