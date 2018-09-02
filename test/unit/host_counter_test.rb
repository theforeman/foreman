require "test_helper"

class HostCounterTest < ActiveSupport::TestCase
  def setup
    User.current = users :admin
  end

  test 'it should get number of hosts associated to model' do
    m = Model.create(:name => "model-1")
    Host.create(:model => m)
    count = HostCounter.new(:model)
    assert_equal 1, count[m]
  end

  test 'it should get number of hosts associated to architecture' do
    os = Architecture.create(:name => "arch-1")
    Host.create(:architecture => os)
    Host.create(:architecture => os)
    count = HostCounter.new(:architecture)
    assert_equal 2, count[os]
  end

  test 'it should count only hosts if user has view_hosts permissions' do
    model = Model.first
    assert Host.create(:model => model)

    as_admin do
      count = HostCounter.new(:model)
      assert_equal 1, count[model]
    end

    # user "one" does not have view hosts permissions
    as_user(:one) do
      count = HostCounter.new(:model)
      assert_equal 0, count[model]
    end
  end

  test 'it should count only hosts in user location/organization' do
    m1 = Model.create(:name => "blabla")
    assert Host.create(:model => m1, :location => Location.first, :organization => Organization.second).save
    assert Host.create(:model => m1, :location => Location.second, :organization => Organization.third).save
    assert_equal 2, HostCounter.new(:model)[m1]

    Location.current = Location.first
    Organization.current = nil
    assert_equal 1, HostCounter.new(:model)[m1]

    Location.current = nil
    Organization.current = Organization.second
    assert_equal 1, HostCounter.new(:model)[m1]

    Location.current = Location.second
    Organization.current = Organization.second
    assert_equal 0, HostCounter.new(:model)[m1]
  end

  test 'it should count hosts associated to location/organization even though current location/organization is set' do
    assert Host.create(:location => Location.first, :organization => Organization.second).save
    assert Host.create(:location => Location.second, :organization => Organization.third).save
    Location.current = Location.first
    Organization.current = Organization.second
    assert_equal 2, HostCounter.new(:organization).hosts_count.count
    assert_equal 2, HostCounter.new(:location).hosts_count.count
  end
end
