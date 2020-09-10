require 'test_helper'

module Mutations
  module Operatingsystems
    class DeleteMutationTest < ActiveSupport::TestCase
      let(:os) { FactoryBot.create(:operatingsystem) }
      let(:os_id) { Foreman::GlobalId.for(os) }
      let(:variables) do
        {
          id: os_id,
        }
      end
      let(:query) do
        <<-GRAPHQL
        mutation DeleteOperatingsystemMutation($id: ID!) {
          deleteOperatingsystem(input: {id: $id}) {
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

        test 'deletes an operating system' do
          context = { current_user: user }

          os

          assert_difference('::Operatingsystem.count', -1) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_empty result['errors']
            assert_empty result['data']['deleteOperatingsystem']['errors']
            assert_equal os_id, result['data']['deleteOperatingsystem']['id']
          end
          assert_equal user.id, Audit.last.user_id
        end
      end

      context 'with user with view permissions' do
        setup do
          os
          @user = setup_user 'view', 'operatingsystems'
        end

        test 'cannot delete an operating system' do
          context = { current_user: @user }

          assert_difference('Operatingsystem.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_not_empty result['errors']
            assert_includes result['errors'].map { |error| error['message'] }.to_sentence, 'Unauthorized.'
          end
        end
      end
    end
  end
end
