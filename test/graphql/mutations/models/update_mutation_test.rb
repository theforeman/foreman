require 'test_helper'

module Mutations
  module Models
    class UpdateMutationTest < ActiveSupport::TestCase
      let(:model) { FactoryBot.create(:model) }
      let(:model_id) { Foreman::GlobalId.for(model) }
      let(:variables) do
        {
          id: model_id,
          name: 'SUN T2000',
          info: 'Sun Sparc Enterprise T2000',
          vendorClass: 'Sun-Fire-T200',
          hardwareModel: 'SUN4V',
        }
      end
      let(:query) do
        <<-GRAPHQL
          mutation updateModelMutation(
              $id: ID!,
              $name: String!,
              $info: String,
              $vendorClass: String,
              $hardwareModel: String
            ) {
            updateModel(input: {
              id: $id,
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

        test 'updates a model' do
          context = { current_user: user }

          model

          assert_difference('::Model.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_empty result['errors']
            assert_empty result['data']['updateModel']['errors']
          end
          assert_equal user.id, Audit.last.user_id
          model.reload
          assert_equal 'SUN T2000', model.name
        end
      end

      context 'with user with view permissions' do
        setup do
          model
          @user = setup_user 'view', 'models'
        end

        test 'cannot update a model' do
          context = { current_user: @user }

          assert_difference('Model.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_not_empty result['errors']
          end
        end
      end
    end
  end
end
