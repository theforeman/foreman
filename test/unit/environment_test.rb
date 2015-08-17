require 'test_helper'

class EnvironmentTest < ActiveSupport::TestCase
  def setup
    Environment.all.each do |e| #because we load from fixtures, counters aren't updated
      Environment.reset_counters(e.id,:hosts)
      Environment.reset_counters(e.id,:hostgroups)
    end
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should have_many(:provisioning_templates).through(:template_combinations)
  should have_many(:puppetclasses).through(:environment_classes)
  should have_many(:trends).class_name('ForemanTrend')
  should allow_mass_assignment_of(:name)

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

  test 'should create environment with the name "new"' do
    assert FactoryGirl.build(:environment, :name => 'new').valid?
  end
end
