require 'test_helper'

module Mutations
  module Bookmarks
    class UpdateMutationTest < ActiveSupport::TestCase
      let(:bookmark) { FactoryBot.create(:bookmark, :owner => users(:one), :controller => 'hosts') }
      let(:bookmark_id) { Foreman::GlobalId.for bookmark }
      let(:variables) do
        {
          id: bookmark_id,
          name: 'changed name',
          query: 'find them all!!!',
          controller: 'domains',
        }
      end
      let(:query) do
        <<-GRAPHQL
          mutation UpdateBookmarkMutation($id: ID!, $name: String!, $query: String!, $controller: String!, $public: Boolean) {
            updateBookmark(input: { id: $id, name: $name, query: $query, controller: $controller, public: $public }){
              bookmark {
                name
                id
                query
                controller
                public
                owner {
                  ... on User {
                    login
                  }
                }
              }
              errors {
                path
                message
              }
            }
          }
        GRAPHQL
      end

      context 'as admin user' do
        let(:user) { FactoryBot.create(:user, :admin) }
        let(:context) { { current_user: user } }

        setup do
          bookmark
        end

        test 'updates a bookmark' do
          assert_difference('::Bookmark.count', 0) do
            result = ForemanGraphqlSchema.execute(query, context: context, variables: variables)
            assert_empty result['errors']
            assert_empty result['data']['updateBookmark']['errors']
          end
          assert_equal user.id, Audit.last.user_id
          bookmark.reload
          assert_equal variables[:name], bookmark.name
          assert_equal variables[:query], bookmark.query
          assert_equal variables[:controller], bookmark.controller
        end

        test 'should not update a bookmark without id' do
          assert_difference('Bookmark.count', 0) do
            result = ForemanGraphqlSchema.execute(query,
              context: context,
              variables: variables.reject { |key, value| key == :id })
            assert_equal "Variable $id of type ID! was provided invalid value", result['errors'].first['message']
            assert_equal "Expected value to not be null", result['errors'].first['problems'].first['explanation']
          end
        end
      end

      context 'as user with view permissions' do
        setup do
          variables
          @user = setup_user 'view', 'bookmarks'
        end

        test 'cannot update a bookmark' do
          context = { current_user: @user }

          assert_difference('Bookmark.count', 0) do
            result = ForemanGraphqlSchema.execute(query, context: context, variables: variables)
            assert_not_empty result['errors']
          end
        end
      end
    end
  end
end
