require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  def setup
    User.current = users(:admin)
  end

  def setup_user operation
    super operation, "organizations"
  end

  test 'it should not save without an empty name' do
    org = Organization.new
    assert !org.save
  end

  test 'it should not save with a blank name' do
    org = Organization.new
    org.name = "   "
    assert !org.save
  end

  test 'it should not save another org with the same name' do
    org = Organization.new
    org.name = "org1"
    assert org.save

    another_org = Organization.new
    another_org.name = "org1"
    assert !another_org.save
  end

  test 'it should show the name for to_s' do
    org = Organization.new :name => "org name"
    assert org.to_s == org.name
  end

  test 'it should save the users associated to an organization' do
    user = setup_user "view"
    as_admin do
      org = Organization.new :name => "org name"
      org.users << user
      org.save!
      assert user.organizations.include? org
    end
  end
end
