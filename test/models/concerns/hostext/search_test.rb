require 'test_helper'

module Hostext
  class SearchTest < ActiveSupport::TestCase
    context 'host exists' do
      setup do
        @host = FactoryBot.create(:host)
      end

      test "can be found by config group" do
        config_group = FactoryBot.create(:config_group)
        @host.config_groups = [ config_group ]
        result = Host.search_for("config_group = #{config_group.name}")
        assert_includes result, @host
      end

      test "search by config group returns only host within that config group" do
        config_group = FactoryBot.create(:config_group)
        result = Host.search_for("config_group = #{config_group.name}")
        assert_not_includes result, @host
      end
    end

    describe 'a host with user search' do
      let(:user) { FactoryBot.create(:user, :with_mail, firstname: 'Jane', lastname: 'Doe') }
      let(:host) { FactoryBot.create(:host, owner: user) }
      let(:other_host) { FactoryBot.create(:host) }

      setup do
        host
        other_host
      end

      context 'with a standalone user' do
        test 'can be searched by current_user' do
          result = User.as(user.login) { Host.search_for('owner = current_user') }
          assert_same_elements result, [host]
          assert_not_includes result, other_host
        end

        test 'can be searched by login' do
          result = Host.search_for("owner = #{user.login}")
          assert_same_elements result, [host]
          assert_not_includes result, other_host
        end

        test 'can be searched by firstname' do
          result = Host.search_for("user.firstname = #{user.firstname}")
          assert_same_elements result, [host]
          assert_not_includes result, other_host
        end

        test 'can be searched by lastname' do
          result = Host.search_for("user.lastname = #{user.lastname}")
          assert_same_elements result, [host]
          assert_not_includes result, other_host
        end

        test 'can be searched by mail' do
          result = Host.search_for("user.mail = #{user.mail}")
          assert_same_elements result, [host]
          assert_not_includes result, other_host
        end

        test 'can be searched by hostname and firstname' do
          result = Host.search_for("name = \"#{host.name}\" and user.firstname = #{user.firstname}")
          assert_same_elements result, [host]
          assert_not_includes result, other_host
        end

        test 'does not find hosts if condition does not match anything' do
          result = Host.search_for('user.firstname = does_not_exist')
          assert_empty result
        end
      end

      context 'with a host owned by a usergroup' do
        let(:usergroup) { FactoryBot.create(:usergroup) }
        let(:usergroup_host) { FactoryBot.create(:host, owner: usergroup) }

        setup do
          usergroup_host
          FactoryBot.create(:user_usergroup_member, usergroup: usergroup, member: user)
        end

        test 'current_user finds a host owned by a usergroup' do
          result = User.as(user.login) { Host.search_for('owner = current_user') }
          assert_same_elements result, [host, usergroup_host]
          assert_not_includes result, other_host
        end

        test 'current_user finds a host owned by a parent usergroup' do
          parent_usergroup = FactoryBot.create(:usergroup)
          parent_usergroup_host = FactoryBot.create(:host, owner: parent_usergroup)

          FactoryBot.create(:usergroup_usergroup_member, usergroup: parent_usergroup, member: usergroup)

          result = User.as(user.login) { Host.search_for('owner = current_user') }
          assert_same_elements result, [host, usergroup_host, parent_usergroup_host]
          assert_not_includes result, other_host
        end

        test 'current_user finds a host by name and owned by a usergroup' do
          result = User.as(user.login) { Host.search_for("name = \"#{host.name}\" and owner = current_user") }
          assert_same_elements result, [host]
          assert_not_includes result, other_host
        end
      end
    end
  end
end
