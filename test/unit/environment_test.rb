require 'test_helper'

class EnvironmentTest < ActiveSupport::TestCase
  def setup
    Environment.all.each do |e| #because we load from fixtures, counters aren't updated
      Environment.reset_counters(e.id,:hosts)
      Environment.reset_counters(e.id,:hostgroups)
    end
  end

  test "should have name" do
    env = Environment.new
    assert !env.valid?
  end

  test "name should be unique" do
    as_admin do
      env = Environment.create :name => "foo"
      env2 = Environment.new :name => env.name
      assert !env2.valid?
    end
  end

  test "to_label should print name" do
    env = Environment.new :name => "foo"
    assert_equal env.to_label, env.name
  end

  test "to_s should print name" do
    env = Environment.new :name => "foo"
    assert_equal env.to_s, env.name
  end

  test "should update hosts_count" do
    environment = environments(:testing)
    assert_difference "environment.hosts_count" do
      FactoryGirl.create(:host).update_attribute(:environment, environment)
      environment.reload
    end
  end

  test "should update hostgroups_count" do
    environment = environments(:testing)
    assert_difference "environment.hostgroups_count" do
      hostgroups(:common).update_attribute(:environment, environment)
      environment.reload
    end
  end
end
