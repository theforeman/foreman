require 'test_helper'

module Mutations
  module Models
    class DeleteMutationTest < GraphQLQueryTestCase
      let(:model) { FactoryBot.create(:model) }
      let(:model_id) { Foreman::GlobalId.for(model) }
      let(:variables) do
        {
          id: model_id,
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
        let(:context_user) { FactoryBot.create(:user, :admin) }

        test 'delete a model' do
          model
          assert_difference(-> { ::Model.count }, -1) do
            assert_empty result['errors']
            assert_empty result['data']['deleteModel']['errors']
            assert_equal model_id, result['data']['deleteModel']['id']
          end
          assert_equal context_user.id, Audit.last.user_id
        end
      end

      context 'with destroy permission' do
        let(:context_user) do
          setup_user('destroy', 'models') do |user|
            user.roles << Role.find_by(name: 'Viewer')
          end
        end

        test 'delete a model' do
          model
          assert_difference(-> { ::Model.count }, -1) do
            assert_empty result['errors']
          end
          assert_equal context_user.id, Audit.last.user_id
        end
      end

      context 'with user with view permissions' do
        let(:context_user) { setup_user('view', 'models') }

        test 'cannot delete a model' do
          model
          assert_difference(-> { ::Model.count }, 0) do
            assert_not_empty result['errors']
            assert_includes result['errors'].map { |error| error['message'] }.to_sentence, 'Unauthorized.'
          end
        end
      end
    end
  end
end
