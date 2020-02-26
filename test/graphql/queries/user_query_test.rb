require 'test_helper'

module Queries
  class UserQueryTest < GraphQLQueryTestCase
    let(:query) do
      <<-GRAPHQL
      query (
        $id: String!
      ) {
        user(id: $id) {
          id
          createdAt
          updatedAt
          login
          admin
          mail
          firstname
          lastname
          fullname
          locale
          timezone
          description
          lastLoginOn
          defaultLocation {
            id
          }
          defaultOrganization {
            id
          }
          personalAccessTokens {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          sshKeys {
            totalCount
            edges {
              node {
                id
              }
            }
          }
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

    let(:location_object) { FactoryBot.create(:location) }
    let(:organization) { FactoryBot.create(:organization) }
    let(:user) do
      FactoryBot.create(:user, :with_mail, :with_usergroup,
        locations: [location_object],
        default_location: location_object,
        organizations: [organization],
        default_organization: organization,
        locale: 'en',
        timezone: 'Berlin')
    end

    let(:global_id) { Foreman::GlobalId.for(user) }
    let(:variables) { { id: global_id } }
    let(:data) { result['data']['user'] }

    setup do
      FactoryBot.create_list(:personal_access_token, 2, user: user)
      FactoryBot.create_list(:ssh_key, 2, user: user)
    end

    test 'fetching user attributes' do
      assert_empty result['errors']

      assert_equal global_id, data['id']
      assert_equal user.created_at.utc.iso8601, data['createdAt']
      assert_equal user.updated_at.utc.iso8601, data['updatedAt']
      assert_equal user.login, data['login']
      assert_equal user.admin, data['admin']
      assert_equal user.mail, data['mail']
      assert_equal user.firstname, data['firstname']
      assert_equal user.lastname, data['lastname']
      assert_equal user.fullname, data['fullname']
      assert_equal user.locale, data['locale']
      assert_equal user.timezone, data['timezone']
      assert_equal user.description, data['description']
      assert_equal user.last_login_on, data['lastLoginOn']

      assert_record user.default_location, data['defaultLocation']
      assert_record user.default_organization, data['defaultOrganization']

      assert_collection user.personal_access_tokens, data['personalAccessTokens']
      assert_collection user.ssh_keys, data['sshKeys']
      assert_collection user.usergroups, data['usergroups']
    end
  end
end
