require 'test_helper'

class SmartProxyReferenceTest < ActiveSupport::TestCase
  setup do
    @ref = SmartProxyReference.new(:domain => [:id])
    @self_ref = SmartProxyReference.new(:self => [:name, :label])
  end

  test 'should be a join reference' do
    assert @ref.join?
  end

  test 'should return column names' do
    assert_equal ['name', 'label'], @self_ref.columns_to_s
  end

  test 'should merge ref' do
    ref = SmartProxyReference.new(:domain => [:name])
    ref.merge @ref
    assert_includes ref.columns, :name
    assert_includes ref.columns, :id
  end

  test 'should be valid' do
    assert @ref.valid?
  end

  test 'should be invalid' do
    refute SmartProxyReference.new(:foo => [:id]).valid?
  end

  test 'should get table name' do
    assert_equal 'domains', @ref.table_name
  end

  test 'should map column names' do
    ref = SmartProxyReference.new(:subnet => [:id])
    assert_equal ['subnets.id'], ref.map_column_names(0)
    assert_equal ['subnets_hosts.id'], ref.map_column_names(1)
  end
end
