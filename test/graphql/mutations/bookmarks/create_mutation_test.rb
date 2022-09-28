require "test_helper"

module Mutations
  module Bookmarks
    class CreateMutationTest < ActiveSupport::TestCase
      let(:variables) do
        {
          name: 'test bookmark',
          query: 'name ~ test',
          controller: 'hosts',
          public: true,
        }
      end

      let(:query) do
        <<-GRAPHQL
          mutation CreateBookmarkMutation($name: String!, $query: String!, $controller: String!, $public: Boolean) {
            createBookmark(input: { name: $name, query: $query, controller: $controller, public: $public }){
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

        test 'create a bookmark' do
          assert_difference('Bookmark.count', +1) do
            result = ForemanGraphqlSchema.execute(query, context: context, variables: variables)
            assert_empty result['errors']
            assert_empty result['data']['createBookmark']['errors']
          end
          assert_equal user.id, Audit.last.user_id
        end

        test 'should not create a bookmark twice' do
          assert_difference('Bookmark.count', +1) do
            result = ForemanGraphqlSchema.execute(query, context: context, variables: variables)
            assert_empty result['errors']
            assert_empty result['data']['createBookmark']['errors']
          end

          assert_difference('Bookmark.count', 0) do
            result = ForemanGraphqlSchema.execute(query, context: context, variables: variables)
            assert_includes result['data']['createBookmark']['errors'], { "path" => ["attributes", "name"], "message" => "has already been taken" }
          end
        end
      end

      context 'as user with view permissions' do
        setup do
          variables
          @user = setup_user 'view', 'bookmarks'
        end

        test 'cannot create a medium' do
          context = { current_user: @user }
          assert_difference('::Bookmark.count', 0) do
            result = ForemanGraphqlSchema.execute(query, context: context, variables: variables)
            assert_not_empty result['errors']
          end
        end
      end
    end
  end
end
