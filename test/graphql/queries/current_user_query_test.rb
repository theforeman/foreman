require 'test_helper'

class Queries::CurrentUserQueryTest < GraphQLQueryTestCase
  let(:query) do
    <<-GRAPHQL
      query {
        currentUser {
          id
          login
          usergroups {
            totalCount
            edges {
              node {
                id
              }
            }
          }
        }
      }
    GRAPHQL
  end
  let(:user) { FactoryBot.create(:user, :with_usergroup) }
  let(:global_id) { Foreman::GlobalId.for(user) }
  let(:variables) { {} }
  let(:data) { result['data']['currentUser'] }

  context 'with logged in user' do
    let(:context) { { current_user: user } }
    test 'fetching current user attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal user.login, data['login']

      assert_collection user.usergroups, data['usergroups']
    end
  end

  context 'without logged in user' do
    let(:context) { { current_user: nil } }

    test 'currentUser returns nil' do
      assert_empty result['errors']
      assert_nil data
    end
  end
end
