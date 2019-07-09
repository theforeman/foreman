require 'test_helper'

module Mutations
  module Models
    class CreateMutationTest < ActiveSupport::TestCase
      let(:variables) do
        {
          name: 'SUN T2000',
          info: 'Sun Sparc Enterprise T2000',
          vendorClass: 'Sun-Fire-T200',
          hardwareModel: 'SUN4V',
        }
      end
      let(:query) do
        <<-GRAPHQL
          mutation createModelMutation(
              $name: String!,
              $info: String,
              $vendorClass: String,
              $hardwareModel: String
            ) {
            createModel(input: {
              name: $name,
              info: $info,
              vendorClass: $vendorClass,
              hardwareModel: $hardwareModel
            }) {
              model {
                id,
                name,
                info,
                vendorClass
                hardwareModel
              },
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

        test 'create a model' do
          context = { current_user: user }

          assert_difference('Model.count', +1) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_empty result['errors']
            assert_empty result['data']['createModel']['errors']
          end
          assert_equal user.id, Audit.last.user_id
        end
      end

      context 'with user with view permissions' do
        setup do
          @user = setup_user 'view', 'models'
        end

        test 'cannot create a model' do
          context = { current_user: @user }

          assert_difference('::Model.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_not_empty result['errors']
          end
        end
      end
    end
  end
end
