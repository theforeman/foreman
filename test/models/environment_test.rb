require 'test_helper'

class EnvironmentTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should have_many(:provisioning_templates).through(:template_combinations)
  should have_many(:puppetclasses).through(:environment_classes)
  should have_many(:trends).class_name('ForemanTrend')

  test "to_label should print name" do
    env = Environment.new :name => "foo"
    assert_equal env.to_label, env.name
  end

  test "to_s should print name" do
    env = Environment.new :name => "foo"
    assert_equal env.to_s, env.name
  end

  test 'should create environment with the name "new"' do
    assert FactoryBot.build(:environment, :name => 'new').valid?
  end

  context 'audited' do
    test 'on creation on of a new environment' do
      environment = Environment.new(:name => 'new_env')

      assert_difference 'environment.audits.count' do
        environment.save!
      end
    end
  end
end
