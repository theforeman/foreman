require 'test_helper'

module Mutations
  module Operatingsystems
    class UpdateMutationTest < ActiveSupport::TestCase
      let(:os) { FactoryBot.create(:operatingsystem) }
      let(:os_id) { Foreman::GlobalId.for(os) }
      let(:os_name) { 'updated_name' }
      let(:architecture) { FactoryBot.create(:architecture) }
      let(:medium) { FactoryBot.create(:medium) }
      let(:ptable) { FactoryBot.create(:ptable) }
      let(:medium_ids) { [Foreman::GlobalId.for(medium)] }
      let(:architecture_ids) { [Foreman::GlobalId.for(architecture)] }
      let(:ptable_ids) { [Foreman::GlobalId.for(ptable)] }
      let(:variables) do
        {
          :id => os_id,
          :name => os_name,
          :mediumIds => medium_ids,
          :ptableIds => ptable_ids,
          :architectureIds => architecture_ids,
        }
      end
      let(:query) do
        <<-GRAPHQL
          mutation UpdateOperatingsystemMutation(
            $id: ID!,
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
              updateOperatingsystem(
                input:{
                  id: $id,
                  name: $name,
                  description: $description,
                  major: $major,
                  minor: $minor,
                  releaseName: $releaseName,
                  family: $family,
                  passwordHash: $passwordHash,
                  architectureIds:$architectureIds,
                  mediumIds: $mediumIds,
                  ptableIds:$ptableIds,
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
                      id
                    }
                  }
                  ptables {
                    nodes {
                      id
                    }
                  }
                  media {
                    nodes {
                      id
                    }
                  }
                }
              }
          }
        GRAPHQL
      end

      context 'with admin user' do
        let(:user) { FactoryBot.create(:user, :admin) }

        test 'updates an operating system' do
          context = { current_user: user }

          os

          assert_difference('::Operatingsystem.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_empty result['errors']
            res = result['data']['updateOperatingsystem']
            assert_empty res['errors']
            assert_equal os_name, res['operatingsystem']['name']
            assert_equal ptable_ids.first, res['operatingsystem']['ptables']["nodes"].first["id"]
            assert_equal architecture_ids.first, res['operatingsystem']['architectures']["nodes"].first["id"]
            assert_equal medium_ids.first, res['operatingsystem']['media']["nodes"].first["id"]
          end
          assert_equal user.id, Audit.last.user_id
          os.reload
          assert_equal os_name, os.name
        end
      end

      context 'with user with view permissions' do
        setup do
          variables
          @user = setup_user 'view', 'operatingsystems'
        end

        test 'cannot update a os' do
          context = { current_user: @user }

          assert_difference('Operatingsystem.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_not_empty result['errors']
          end
        end
      end
    end
  end
end
