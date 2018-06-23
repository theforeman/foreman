require 'test_helper'

module Mutations
  module Models
    class DeleteMutationTest < ActiveSupport::TestCase
      let(:model) { FactoryBot.create(:model) }
      let(:model_id) { Foreman::GlobalId.for(model) }
      let(:variables) do
        {
          id: model_id
        }
      end
      let(:query) do
        <<-GRAPHQL
        mutation deleteModelMutation($id: ID!) {
          deleteModel(input: {id: $id}) {
            id,
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

        test 'deletes a model' do
          context = { current_user: user }

          model

          assert_difference('::Model.count', -1) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_empty result['errors']
            assert_empty result['data']['deleteModel']['errors']
            assert_equal model_id, result['data']['deleteModel']['id']
          end
          assert_equal user.id, Audit.last.user_id
        end
      end

      context 'with user with view permissions' do
        setup do
          model
          @user = setup_user 'view', 'models'
        end

        test 'cannot delete a model' do
          context = { current_user: @user }

          assert_difference('Model.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_not_empty result['errors']
            assert_includes result['errors'].map { |error| error['message'] }.to_sentence, 'Unauthorized.'
          end
        end
      end
    end
  end
end
