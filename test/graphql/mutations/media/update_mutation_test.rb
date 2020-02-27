require 'test_helper'

module Mutations
  module Media
    class UpdateMutationTest < ActiveSupport::TestCase
      let(:medium) { FactoryBot.create(:medium) }
      let(:medium_id) { Foreman::GlobalId.for(medium) }
      let(:os_id) { Foreman::GlobalId.for(FactoryBot.create(:operatingsystem)) }
      let(:org_id) { Foreman::GlobalId.for(FactoryBot.create(:organization)) }
      let(:loc_id) { Foreman::GlobalId.for(FactoryBot.create(:location)) }
      let(:variables) do
        {
          id: medium_id,
          name: 'My golden medium',
          path: 'https://my-medium.net',
          osFamily: 'Redhat',
          operatingsystemIds: [os_id],
          organizationIds: [org_id],
          locationIds: [loc_id],
        }
      end
      let(:query) do
        <<-GRAPHQL
        mutation UpdateMediumMutation(
            $id: ID!,
            $name: String!,
            $path: String!,
            $osFamily: OsFamilyEnum,
            $operatingsystemIds: [ID!]
            $organizationIds: [ID!]
            $locationIds: [ID!]
          ){
          updateMedium(input: {
            id: $id,
            name: $name,
            path: $path,
            osFamily: $osFamily,
            operatingsystemIds: $operatingsystemIds,
            organizationIds: $organizationIds,
            locationIds: $locationIds
          }) {
            medium {
              id
              name
              path
              osFamily
              operatingsystems {
                nodes {
                  name
                }
              }
              organizations {
                nodes {
                  name
                }
              }
              locations {
                nodes {
                  name
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

      context 'with admin user' do
        let(:user) { FactoryBot.create(:user, :admin) }
        let(:context) { { current_user: user } }

        setup do
          medium
        end

        test 'updates a medium' do
          assert_difference('::Medium.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_empty result['errors']
            assert_empty result['data']['updateMedium']['errors']
          end
          assert_equal user.id, Audit.last.user_id
          medium.reload
          assert_equal variables[:name], medium.name
          assert_equal variables[:path], medium.path
          assert_equal variables[:osFamily], medium.os_family
          refute_empty medium.operatingsystems
          refute_empty medium.locations
          refute_empty medium.organizations
        end

        test 'should not update a medium without id' do
          assert_difference('Medium.count', 0) do
            result = ForemanGraphqlSchema.execute(query,
              variables: variables.reject { |key, value| key == :id },
              context: context)
            assert_equal "Variable id of type ID! was provided invalid value", result['errors'].first['message']
            assert_equal "Expected value to not be null", result['errors'].first['problems'].first['explanation']
          end
        end

        test 'should not update a medium without required args' do
          assert_difference('Medium.count', 0) do
            result = ForemanGraphqlSchema.execute(query,
              variables: variables.reject { |key, value| key == :name || key == :path },
              context: context)
            assert_equal 2, result['errors'].count
            errors = result['errors'].map { |hash| hash['message'] }
            ["Variable name of type String! was provided invalid value", "Variable path of type String! was provided invalid value"].each do |msg|
              assert errors.include? msg
            end
          end
        end

        test 'should not update a medium with invalid os family' do
          assert_difference('Medium.count', 0) do
            result = ForemanGraphqlSchema.execute(query,
              variables: variables.map { |key, value| (key == :osFamily) ? [key, 'foo'] : [key, value] }.to_h,
              context: context)
            assert_equal 1, result['errors'].count
            assert_equal "Variable osFamily of type OsFamilyEnum was provided invalid value", result['errors'].first['message']
            assert_equal "Expected \"foo\" to be one of: #{Types::OsFamilyEnum.values.keys.join(', ')}", result['errors'].first['problems'].first['explanation']
          end
        end
      end

      context 'with user with view permissions' do
        setup do
          variables
          view_role = roles(:viewer)
          user = users(:one)
          user.roles << view_role
          @user = user
        end

        test 'cannot update a medium' do
          context = { current_user: @user }

          assert_difference('Medium.count', 0) do
            result = ForemanGraphqlSchema.execute(query, variables: variables, context: context)
            assert_equal "Unauthorized. You do not have the required permission edit_media.", result['errors'].first['message']
          end
        end
      end
    end
  end
end
