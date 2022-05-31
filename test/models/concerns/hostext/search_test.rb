require 'test_helper'

module Hostext
  class SearchTest < ActiveSupport::TestCase
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

        test 'can be searched by id' do
          result = Host.search_for("id = \"#{host.id}\" and user.firstname = #{user.firstname}")
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

      context "search by facts" do
        let (:host) { FactoryBot.create(:host) }
        let (:fact_name) { FactoryBot.create(:fact_name, :compose => true) }
        let (:fact_value) { FactoryBot.create(:fact_value, :host => host, :fact_name => fact_name) }

        test "searching fact returns correct host" do
          result = Host.search_for("name=#{host.name} or facts.goofy=bad_value")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)

          assert_empty(Host.search_for("name=#{host.name} and facts.goofy=bad_value"))
          result = Host.search_for("name=#{host.name} and facts.#{fact_name.name}=#{fact_value.value}")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test "invalid fact property should properly format" do
          assert_match /\'goofy.bad\'/, Host.search_for("facts.goofy.bad=value").to_sql
          assert_match /\'goofy\'/, Host.search_for("facts.goofy=value").to_sql
        end

        test "searching fact on complex search returns correct host" do
          host1 = FactoryBot.create(:host)
          name1 = FactoryBot.create(:fact_name, :compose => true)
          value1 = FactoryBot.create(:fact_value, :host => host1, :fact_name => name1)

          result = Host.search_for("facts.#{fact_name.name}=#{fact_value.value} or facts.#{name1.name}=#{value1.value}")
          assert_equal(2, result.count)
          assert_includes result.map(&:id), host.id
          assert_includes result.map(&:id), host1.id

          result = Host.search_for("facts.#{fact_name.name}=#{value1.value} or facts.#{name1.name}=#{fact_value.value}")
          assert_empty result
        end
      end

      context "search by operatingsystem major and minor" do
        let (:operatingsystem1) { FactoryBot.create(:operatingsystem, :major => '7', :minor => '6.1810') }
        let (:host) { FactoryBot.create(:host, :operatingsystem => operatingsystem1) }

        test "searching os_major > 5 returns correct host" do
          result = Host.search_for("os_major > 5")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test "searching os_major < 10 returns correct host" do
          result = Host.search_for("os_major < 10")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test "searching os_major = 7 returns correct host" do
          result = Host.search_for("os_major = 7")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test "searching os_major <= 7 returns correct host" do
          result = Host.search_for("os_major <= 7")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test "searching os_major >= 7 returns correct host" do
          result = Host.search_for("os_major >= 7")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test "searching os_major < 5 returns correct host" do
          result = Host.search_for("os_major < 5")
          assert_equal(0, result.count)
          assert_empty result
        end

        test "searching os_minor > 6.2 returns correct host" do
          result = Host.search_for("os_minor > 6.2")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test "searching os_minor <10 returns correct host" do
          result = Host.search_for("os_minor < 10")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test "searching os_minor = 6.1810 returns correct host" do
          result = Host.search_for("os_minor = 6.1810")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test "searching os_minor <= 6.1810 returns correct host" do
          result = Host.search_for("os_minor <= 6.1810")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test "searching  >= 6.1810 returns correct host" do
          result = Host.search_for("os_minor >= 6.1810")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test "searching os_minor < 6 returns correct host" do
          result = Host.search_for("os_minor < 6")
          assert_equal(0, result.count)
          assert_empty result
        end

        test "searching os_minor < 3 returns correct host" do
          os1 = FactoryBot.create(:operatingsystem, :major => '6', :minor => nil)
          FactoryBot.create(:host, :operatingsystem => os1)
          result = Host.search_for("os_minor < 6")
          assert_equal(0, result.count)
          assert_empty result
        end

        test 'searching os_minor != 5 returns correct host' do
          os1 = FactoryBot.create(:operatingsystem, :major => '6', :minor => '5')
          FactoryBot.create(:host, :operatingsystem => os1)
          result = Host.search_for("os_minor != 5")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test 'searching os_minor ~ 6 returns correct host' do
          os1 = FactoryBot.create(:operatingsystem, :major => '6', :minor => '5.3.21')
          FactoryBot.create(:host, :operatingsystem => os1)
          result = Host.search_for("os_minor ~ 6")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end

        test 'searching os_minor !~ 5 returns correct host' do
          os1 = FactoryBot.create(:operatingsystem, :major => '6', :minor => '5.3.21')
          FactoryBot.create(:host, :operatingsystem => os1)
          result = Host.search_for("os_minor !~ 5")
          assert_equal(1, result.count)
          assert_equal(host.id, result.first.id)
        end
      end

      context "search by build status" do
        let(:built_status) do
          HostStatus::BuildStatus.create(
            status: HostStatus::BuildStatus::BUILT,
            host: FactoryBot.create(:host)
          )
        end
        let(:build_failed_status) do
          HostStatus::BuildStatus.create(
            status: HostStatus::BuildStatus::BUILD_FAILED,
            host: FactoryBot.create(:host)
          )
        end

        subject { Host.search_for('build_status = built') }

        setup do
          built_status
          build_failed_status
        end

        it { assert_includes(subject, built_status.host) }
        it { assert_not_includes(subject, build_failed_status.host) }
      end
    end
  end
end
