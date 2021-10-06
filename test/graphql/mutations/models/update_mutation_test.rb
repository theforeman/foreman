require 'test_helper'

module Mutations
  module Models
    class UpdateMutationTest < GraphQLQueryTestCase
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
        let(:context_user) { FactoryBot.create(:user, :admin) }

        test 'update a model' do
          model

          assert_difference(-> { ::Model.count }, 0) do
            assert_empty result['errors']
            assert_empty result['data']['updateModel']['errors']
          end
          assert_equal context_user.id, Audit.last.user_id
          model.reload
          assert_equal 'SUN T2000', model.name
        end
      end

      context 'with invalid name' do
        let(:context_user) { FactoryBot.create(:user, :admin) }
        let(:variables) { { id: model_id, name: '' } }

        test 'should return original name value' do
          model

          assert_difference(-> { ::Model.count }, 0) do
            assert_empty result['errors']
          end
          model.reload
          returned_name = result['data']['updateModel']['model']['name']
          assert_not_empty returned_name
          assert_equal model.name, returned_name
          error = result['data']['updateModel']['errors'].first
          assert_equal ['attributes', 'name'], error['path']
          assert_equal "can't be blank", error['message']
        end
      end

      context 'with edit permission' do
        let(:context_user) do
          setup_user('edit', 'models') do |user|
            user.roles << Role.find_by(name: 'Viewer')
          end
        end

        test 'update a model' do
          model

          assert_difference(-> { ::Model.count }, 0) do
            assert_empty result['errors']
          end
          assert_equal context_user.id, Audit.last.user_id
          model.reload
          assert_equal 'SUN T2000', model.name
        end
      end

      context 'with user with view permissions' do
        let(:context_user) { setup_user('view', 'models') }

        test 'cannot update a model' do
          model

          assert_difference(-> { ::Model.count }, 0) do
            assert_not_empty result['errors']
          end
        end
      end
    end
  end
end
