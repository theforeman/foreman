require 'test_helper'

class EnsureNotUsedByTest < ActiveSupport::TestCase
  def setup
    @org1 = FactoryBot.build(:organization)
    @org2 = FactoryBot.build(:organization)
    @user = FactoryBot.build(:user, :with_mail, :organizations => [@org1])
    @user.save(:validate => false)
    role = FactoryBot.build(:role, :name => 'can_view_host')
    role.add_permissions!(['view_hosts'])
    @user.update_attribute :roles, [role]
  end

  test "hostgroup should not be deleted if used by host in user org" do
    hostgroup = FactoryBot.create(:hostgroup, :with_domain, :with_os, :organizations => [@org1, @org2])
    host = FactoryBot.create(:host, :managed, :hostgroup => hostgroup, :organization => @org1)

    as_user @user do
      in_taxonomy @org1 do
        refute hostgroup.destroy
        assert_equal "#{hostgroup.name} is used by #{host.name}", hostgroup.errors.full_messages.first
      end
    end
  end

  test "hostgroup should not be deleted if used by host in different org" do
    hostgroup = FactoryBot.create(:hostgroup, :with_domain, :with_os, :organizations => [@org1, @org2])
    FactoryBot.create(:host, :hostgroup => hostgroup, :organization => @org2)

    as_user @user do
      in_taxonomy @org1 do
        refute hostgroup.destroy
        assert_equal "#{hostgroup.name} is being used by a hidden Host::Managed resource", hostgroup.errors.full_messages.first
      end
    end
  end

  test "hostgroup should not be deleted if used by host" do
    hostgroup = FactoryBot.create(:hostgroup, :with_domain, :with_os, :organizations => [@org1, @org2])
    FactoryBot.create(:host, :hostgroup => hostgroup, :organization => @org2)

    as_user FactoryBot.build(:user, :with_mail) do
      in_taxonomy @org1 do
        refute hostgroup.destroy
        assert_equal "#{hostgroup.name} is being used by a hidden Host::Managed resource", hostgroup.errors.full_messages.first
      end
    end
  end

  test "hostgroup should be deleted if not used by host" do
    hostgroup = FactoryBot.build(:hostgroup, :organizations => [@org1, @org2])
    FactoryBot.build(:host, :organization => @org2)

    as_user @user do
      assert hostgroup.destroy
    end
  end

  test "host using hostgroup should not be shown to user without permissions" do
    hostgroup = FactoryBot.create(:hostgroup, :with_domain, :with_os)
    FactoryBot.create(:host, :managed, :hostgroup => hostgroup)

    as_user  FactoryBot.build(:user, :with_mail) do
      refute hostgroup.destroy
      assert_equal "#{hostgroup.name} is being used by a hidden Host::Managed resource", hostgroup.errors.full_messages.first
    end
  end
end
