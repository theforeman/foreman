require 'test_helper'

module Mutations
  module Models
    class CreateMutationTest < GraphQLQueryTestCase
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
        let(:context_user) { FactoryBot.create(:user, :admin) }

        test 'create a model' do
          assert_difference(-> { ::Model.count }, +1) do
            assert_empty result['errors']
            assert_empty result['data']['createModel']['errors']
          end
          assert_equal context_user.id, Audit.last.user_id
        end
      end

      context 'with create permission' do
        let(:context_user) { setup_user('create', 'models') }

        test 'create a model' do
          assert_difference(-> { ::Model.count }, +1) do
            assert_empty result['errors']
          end
          assert_equal context_user.id, Audit.last.user_id
        end
      end

      context 'with user with view permissions' do
        let(:context_user) { setup_user('view', 'models') }

        test 'cannot create a model' do
          expected_error = 'Unauthorized. You do not have the required permission create_models.'

          assert_difference(-> { ::Model.count }, 0) do
            assert_not_empty result['errors']
            assert_includes result['errors'].map { |e| e['message'] }, expected_error
          end
        end
      end
    end
  end
end
