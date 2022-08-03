require 'test_helper'

class TableTest < ActiveSupport::TestCase
  test 'should store category definitions' do
    table = Foreman::SelectableColumns::Table.new(:test)
    table.category(:test) {}
    table.category(:test2) {}

    assert_not_empty table
  end

  test 'should re-use category definitions' do
    table = Foreman::SelectableColumns::Table.new(:test)
    table.category(:test) {}
    table.category(:test) {}

    assert_equal 1, table.size
  end
end
