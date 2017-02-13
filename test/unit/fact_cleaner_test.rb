require 'test_helper'

class FactCleanerTest < ActiveSupport::TestCase
  let(:cleaner) do
    FactCleaner.new
  end

  test "it cleans orhpaned root leaves" do
    root_1_fact = FactoryGirl.create(:fact_name)
    cleaner.clean!
    assert_not_include remaining_of(root_1_fact), root_1_fact
  end

  test "it cleans root composes without any leaves" do
    root_2_fact = FactoryGirl.create(:fact_name, :compose => true)
    cleaner.clean!
    assert_not_include remaining_of(root_2_fact), root_2_fact
  end

  test "it cleans composes and it's leaves composes if there are no values for them" do
    root_3_fact = FactoryGirl.create(:fact_name, :compose => true)
    root_3_child_fact = FactoryGirl.create(:fact_name, :parent_id => root_3_fact.id)
    cleaner.clean!
    remaining = remaining_of(root_3_fact, root_3_child_fact)
    assert_not_include remaining, root_3_fact
    assert_not_include remaining, root_3_child_fact
  end

  test "it keeps composes and their only children that have values" do
    root_4_fact = FactoryGirl.create(:fact_name, :compose => true)
    root_4_child_1_fact = FactoryGirl.create(:fact_name, :parent_id => root_4_fact.id)
    # root_4_child_1_fact_value
    FactoryGirl.create(:fact_value, :fact_name => root_4_child_1_fact)
    root_4_child_2_fact = FactoryGirl.create(:fact_name, :parent_id => root_4_fact.id)

    cleaner.clean!
    remaining = remaining_of(root_4_fact, root_4_child_1_fact, root_4_child_2_fact)
    assert_include remaining, root_4_fact
    assert_include remaining, root_4_child_1_fact
    assert_not_include remaining, root_4_child_2_fact
  end

  test "it keeps root leaves if the have value" do
    root_6_fact = FactoryGirl.create(:fact_name)
    # root_6_fact_value
    FactoryGirl.create(:fact_value, :fact_name => root_6_fact)
    cleaner.clean!
    assert_include remaining_of(root_6_fact), root_6_fact
  end

  private

  def remaining_of(*names)
    FactName.where(:name => names.map(&:name))
  end
end
