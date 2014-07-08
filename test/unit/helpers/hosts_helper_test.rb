require 'test_helper'

class HostsHelperTest < ActionView::TestCase

  def test_admin_should_see_compute_resources_and_bare_metal_options
    assert as_admin { available_compute_resources[0] }.include?("Bare Metal")
  end

  def test_user_without_view_hosts_should_not_see_bare_metal_option
    permission = FactoryGirl.create(:permission, :name => 'view_compute_resources')
    role = FactoryGirl.build(:role, :permissions => [permission])
    user = users(:one)
    user.roles << role

    assert !(as_user(:one) { available_compute_resources }.collect{|cr| cr[0]}.include?("Bare Metal"))
  end

  def test_user_without_view_computeresources_should_not_see_them
    permission = FactoryGirl.create(:permission, :name => 'view_hosts')
    role = FactoryGirl.build(:role, :permissions => [permission])
    user = users(:one)
    user.roles << role

    assert (as_user(:one) { available_compute_resources }.none? {|cr| cr[0] != "Bare Metal"})
  end
end
