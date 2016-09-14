require 'test_helper'

class HostAndHostGroupsHelperTest < ActionView::TestCase
  include HostsAndHostgroupsHelper

  setup do
    permission = Permission.find_by_name('view_domains')
    filter = FactoryGirl.create(:filter, :on_name_starting_with_a,
                                :permissions => [permission])
    @user = FactoryGirl.create(:user)
    @user.update_attribute :roles, [filter.role]
    @domain1 = FactoryGirl.create(:domain, :name => 'a-domain.to-be-found.com')
    @domain2 = FactoryGirl.create(:domain, :name => 'domain-not-to-be-found.com')
  end

  test "accessible_resource_records returns only authorized records" do
    as_user @user do
      records = accessible_resource_records(:domain)
      assert records.include? @domain1
      refute records.include? @domain2
    end
  end

  test "accessible_resource includes current value even if not authorized" do
    host = FactoryGirl.create(:host, :domain => @domain2)
    domain3 = FactoryGirl.create(:domain, :name => 'one-more-not-to-be-found.com')
    as_user @user do
      resources = accessible_resource(host, :domain)
      assert resources.include? @domain1
      assert resources.include? @domain2
      refute resources.include? domain3
    end
  end

  test "accessible_related_resource shows only authorized related records" do
    permission = Permission.find_by_name('view_subnets')
    filter = FactoryGirl.create(:filter, :on_name_starting_with_a,
                                :permissions => [permission])
    @user.roles << filter.role
    subnet1 = FactoryGirl.create(:subnet_ipv4, :name => 'a subnet', :domains => [@domain1])
    subnet2 = FactoryGirl.create(:subnet_ipv4, :name => 'some other subnet', :domains => [@domain1])
    subnet3 = FactoryGirl.create(:subnet_ipv4, :name => 'a subnet in anoter domain', :domains => [@domain2])
    as_user @user do
      resources = accessible_related_resource(@domain1, :subnets)
      assert resources.include? subnet1
      refute resources.include? subnet2
      refute resources.include? subnet3
    end
  end
end
