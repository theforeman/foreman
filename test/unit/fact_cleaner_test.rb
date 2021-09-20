require 'test_helper'
require 'fact_importer_test_helper'

class FactCleanerTest < ActiveSupport::TestCase
  let(:null_store) { ActiveSupport::Cache.lookup_store(:null_store) }
  let(:cleaner) do
    FactCleaner.new
  end

  test "it cleans orhpaned root leaves" do
    root_1_fact = FactoryBot.build(:fact_name)
    cleaner.clean!
    assert_not_include remaining_of(root_1_fact), root_1_fact
  end

  test "it cleans root composes without any leaves" do
    root_2_fact = FactoryBot.build(:fact_name, :compose => true)
    cleaner.clean!
    assert_not_include remaining_of(root_2_fact), root_2_fact
  end

  test "it cleans composes and it's leaves composes if there are no values for them" do
    root_3_fact = FactoryBot.build(:fact_name, :compose => true)
    root_3_child_fact = FactoryBot.build(:fact_name, :parent_id => root_3_fact.id)
    cleaner.clean!
    remaining = remaining_of(root_3_fact, root_3_child_fact)
    assert_not_include remaining, root_3_fact
    assert_not_include remaining, root_3_child_fact
  end

  test "it keeps composes and their only children that have values" do
    root_4_fact = FactoryBot.create(:fact_name, :compose => true)
    root_4_child_1_fact = FactoryBot.create(:fact_name, :parent_id => root_4_fact.id)
    # root_4_child_1_fact_value
    FactoryBot.create(:fact_value, :fact_name => root_4_child_1_fact)
    root_4_child_2_fact = FactoryBot.create(:fact_name, :parent_id => root_4_fact.id)

    cleaner.clean!
    remaining = remaining_of(root_4_fact, root_4_child_1_fact, root_4_child_2_fact)
    assert_include remaining, root_4_fact
    assert_include remaining, root_4_child_1_fact
    assert_not_include remaining, root_4_child_2_fact
  end

  test "it keeps root leaves if the have value" do
    root_6_fact = FactoryBot.create(:fact_name)
    # root_6_fact_value
    FactoryBot.create(:fact_value, :fact_name => root_6_fact)
    cleaner.clean!
    assert_include remaining_of(root_6_fact), root_6_fact
  end

  test "it cleans excluded facts" do
    Setting.stubs(:cache).returns(null_store)
    Setting[:excluded_facts] = ['ignored*', '*bad']
    cleaner.stubs(:delete_orphaned_facts).returns(0)
    good_fact_name = FactoryBot.create(:fact_name, :name => 'good_fact')
    ignored_fact_name = FactoryBot.create(:fact_name, :name => 'ignored01')
    bad_fact_name = FactoryBot.create(:fact_name, :name => 'empty_bad')
    FactoryBot.create(:fact_value, :fact_name => good_fact_name)
    FactoryBot.create(:fact_value, :fact_name => ignored_fact_name)
    cleaner.clean!
    assert_equal 2, cleaner.deleted_count
    assert_include remaining_of(good_fact_name, ignored_fact_name, bad_fact_name), good_fact_name
  end

  test 'it cleans ignored flat facts' do
    Setting.stubs(:cache).returns(null_store)
    [
      FactsData::FlatFacts,
      FactsData::RhsmStyleFacts,
      FactsData::FlatPuppetStyleFacts,
    ].each do |data_class|
      data = data_class.new

      facts = data.good_facts.merge(data.ignored_facts)
      fact_records = []

      facts.keys.each do |fact_name|
        fact_records << FactoryBot.create(:fact_name, :name => fact_name)
      end

      Setting[:excluded_facts] = data.filter
      cleaner.stubs(:delete_orphaned_facts).returns(0)

      cleaner.clean!

      expected_names = data.good_facts.keys.sort
      actual_names = remaining_of(*fact_records).order(:name).pluck(:name)
      assert_equal expected_names, actual_names
    end
  end

  test 'it cleans ignored hierarchical facts' do
    Setting.stubs(:cache).returns(null_store)
    data = FactsData::HierarchicalPuppetStyleFacts.new

    facts_hierarchy = data.good_facts.deep_merge(data.ignored_facts)
    importer = FactImporters::Structured.new(nil, nil, facts_hierarchy)
    facts = importer.send(:facts)
    fact_records = []

    facts.keys.each do |fact_name|
      fact_records << FactoryBot.create(:fact_name, :name => fact_name)
    end

    Setting[:excluded_facts] = data.filter
    cleaner.stubs(:delete_orphaned_facts).returns(0)

    cleaner.clean!

    # empty_ancestor can't be removed by the cleaner,
    # at least without too much code
    expected_names = (data.flat_result.keys + ['empty_ancestor']).sort
    actual_names = remaining_of(*fact_records).order(:name).pluck(:name)
    assert_equal expected_names, actual_names
  end

  private

  def remaining_of(*names)
    FactName.where(:name => names.map(&:name))
  end
end
