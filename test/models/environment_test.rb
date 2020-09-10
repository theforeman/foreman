require 'test_helper'

class EnvironmentTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should have_many(:provisioning_templates).through(:template_combinations)
  should have_many(:puppetclasses).through(:environment_classes)

  # List of valid environment names.
  def valid_env_name_list
    [
      RFauxFactory.gen_alphanumeric(1),
      RFauxFactory.gen_alphanumeric(255),
      RFauxFactory.gen_alphanumeric(rand(1..254)),
      RFauxFactory.gen_alpha(rand(1..254)),
      RFauxFactory.gen_numeric_string(rand(1..254)),
    ]
  end

  # List of invalid environment names.
  def invalid_env_name_list
    [
      RFauxFactory.gen_cjk,
      RFauxFactory.gen_latin1,
      RFauxFactory.gen_utf8,
      RFauxFactory.gen_alpha(256),
      RFauxFactory.gen_numeric_string(256),
      RFauxFactory.gen_alphanumeric(256),
      RFauxFactory.gen_html(249),
    ]
  end

  test "to_label should print name" do
    env = Environment.new :name => "foo"
    assert_equal env.to_label, env.name
  end

  test "to_s should print name" do
    env = Environment.new :name => "foo"
    assert_equal env.to_s, env.name
  end

  test 'should create environment with the name "new"' do
    assert FactoryBot.build_stubbed(:environment, :name => 'new').valid?
  end

  test 'should create with multiple valid names' do
    valid_env_name_list.each do |name|
      env = FactoryBot.build(:environment, :name => name)
      assert env.valid?, "Can't create environment with valid name #{name}"
    end
  end

  test 'should not create with multiple invalid names' do
    invalid_env_name_list.each do |name|
      env = FactoryBot.build(:environment, :name => name)
      refute env.valid?, "Can create environment with invalid name #{name}"
      assert_includes env.errors.keys, :name
    end
  end

  test 'should update with multiple valid names' do
    env = FactoryBot.create(:environment)
    valid_env_name_list.each do |name|
      env.name = name
      assert env.valid?, "Can't update environment with valid name #{name}"
    end
  end

  test 'should not update with multiple invalid names' do
    env = FactoryBot.create(:environment)
    invalid_env_name_list.each do |name|
      env.name = name
      refute env.valid?, "Can update environment with invalid name #{name}"
      assert_includes env.errors.keys, :name
    end
  end

  context 'audited' do
    test 'on creation on of a new environment' do
      environment = FactoryBot.build(:environment, :with_auditing)

      assert_difference 'environment.audits.count' do
        environment.save!
      end
    end
  end
end
