require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  let(:table) { Foreman::SelectableColumns::Table.new(name: 'foo') }

  test 'should store column definitions' do
    category = Foreman::SelectableColumns::Category.new(:test, 'Test', table)
    category.column :key, th: {}, td: {}
    category.column :key2, th: {}, td: {}

    assert_not_empty category.columns
  end

  test 'should re-use column definitions' do
    shared_table = table
    category1 = Foreman::SelectableColumns::Category.new('test', 'Test', shared_table)
    category1.column :key, th: {}, td: {}
    category2 = Foreman::SelectableColumns::Category.new('test2', 'Test2', shared_table)
    category2.use_column :key, from: :test
    shared_table.concat([category1, category2])

    assert_not_empty category2.columns
  end

  test 'should ignore non-existing category for re-usage' do
    shared_table = table
    category2 = Foreman::SelectableColumns::Category.new('test2', 'Test2', shared_table)
    category2.use_column :key, from: :test3
    shared_table.concat([category2])

    assert_empty category2.columns
  end

  test 'should ignore non-existing column for re-usage' do
    shared_table = table
    category1 = Foreman::SelectableColumns::Category.new('test', 'Test', shared_table)
    category1.column :key, th: {}, td: {}
    category2 = Foreman::SelectableColumns::Category.new('test2', 'Test2', shared_table)
    category2.use_column :key2, from: :test
    shared_table.concat([category1, category2])

    assert_empty category2.columns
  end

  test 'should ignore itself for re-usage' do
    shared_table = table
    category2 = Foreman::SelectableColumns::Category.new('test2', 'Test2', shared_table)
    category2.use_column :key, from: :test2
    shared_table.concat([category2])

    assert_empty category2.columns
  end
end
