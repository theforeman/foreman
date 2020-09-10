require 'test_helper'

class HostextOwnershipTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = users :admin
  end

  context 'owner_type validations' do
    test "should not save if owner_type is not User or Usergroup" do
      host = Host.new :name => "myfullhost", :mac => "aabbecddeeff", :ip => "3.3.4.03", :medium => media(:one),
                      :domain => domains(:mydomain), :operatingsystem => operatingsystems(:redhat), :subnet => subnets(:two), :puppet_proxy => smart_proxies(:puppetmaster),
                      :architecture => architectures(:x86_64), :environment => environments(:production), :managed => true,
                      :owner_type => "UserGr(up" # should be Usergroup
      assert_raises ArgumentError do
        host.valid?
      end
    end

    test "should save if owner_type is User or Usergroup" do
      host = FactoryBot.build_stubbed(:host, :owner_type => "User", :owner => User.current)
      assert_valid host
    end

    test 'should succeed validation if owner not set' do
      host = FactoryBot.build_stubbed(:host, :without_owner)
      assert_valid host
    end

    test "should not save if owner_type is set without owner" do
      host = FactoryBot.build_stubbed(:host, :owner_type => "Usergroup")
      refute_valid host
      assert_match(/owner must be specified/, host.errors[:owner].first)
    end

    test "should not save if owner_type is not in sync with owner" do
      host = FactoryBot.build_stubbed(:host, :owner => User.current)
      host.owner_type = 'Usergroup'
      refute_valid host
      assert_match(/Usergroup/, host.errors[:owner].first)
    end
  end

  test "should use current user as host owner if host owner setting is empty" do
    Setting[:host_owner] = ''
    h = FactoryBot.build_stubbed(:host, :managed)
    h.validate
    assert_equal User.current, h.owner
  end

  context "with host owner setting" do
    setup do
      user = users(:one)
      Setting[:host_owner] = user.id_and_type
    end

    test "should use host owner setting if it exists" do
      h = FactoryBot.build_stubbed(:host, :managed)
      h.validate
      assert_equal users(:one), h.owner
    end

    test "should use host owner if it exist in params" do
      h = FactoryBot.build_stubbed(:host, :managed, :owner => users(:two))
      h.validate
      assert_equal users(:two), h.owner
    end

    test "should use assume the type is User if not set explicitly" do
      h = FactoryBot.build_stubbed(:host, :managed, :owner_id => users(:two).id)
      h.validate
      assert_equal users(:two), h.owner
    end
  end

  test "search by user returns only the relevant hosts" do
    host = nil
    as_user :one do
      host = FactoryBot.build(:host)
    end
    refute_equal User.current, host.owner
    results = Host.search_for("owner = " + User.current.login)
    refute results.include?(host)
  end

  test "can auto-complete owner searches by current_user" do
    as_admin do
      completions = Host::Managed.complete_for("owner = ")
      assert completions.include?("owner = current_user"), "completion missing: current_user"
    end
  end

  test "can search hosts by owner" do
    FactoryBot.create(:host)
    results = Host.search_for("owner = " + User.current.login)
    assert_equal User.current.hosts.count, results.count
    assert_equal results[0].owner, User.current
  end
end
