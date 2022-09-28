require 'test_helper'

module Mutations
  module Media
    class DeleteMutationTest < ActiveSupport::TestCase
      let(:medium) { FactoryBot.create(:medium) }
      let(:medium_id) { Foreman::GlobalId.for(medium) }
      let(:variables) do
        {
          id: medium_id,
        }
      end
      let(:query) do
        <<-GRAPHQL
        mutation DeleteMediumMutation($id:ID!){
          deleteMedium(input:{id:$id}) {
            id
            errors {
              message
              path
            }
          }
        }
        GRAPHQL
      end

      context 'with admin user' do
        let(:user) { FactoryBot.create(:user, :admin) }

        test 'deletes a model' do
          context = { current_user: user }

          medium

          assert_difference('::Medium.count', -1) do
            result = ForemanGraphqlSchema.execute(query, context: context, variables: variables)
            assert_empty result['errors']
            assert_empty result['data']['deleteMedium']['errors']
            assert_equal medium_id, result['data']['deleteMedium']['id']
          end
          assert_equal user.id, Audit.last.user_id
        end
      end

      context 'with user with view permissions' do
        setup do
          medium
          @user = setup_user 'view', 'media'
        end

        test 'cannot delete a model' do
          context = { current_user: @user }

          assert_difference('Medium.count', 0) do
            result = ForemanGraphqlSchema.execute(query, context: context, variables: variables)
            assert_not_empty result['errors']
            assert_includes result['errors'].map { |error| error['message'] }.to_sentence, 'Unauthorized.'
          end
        end
      end
    end
  end
end
