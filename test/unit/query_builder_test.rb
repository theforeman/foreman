require 'test_helper'

class QueryBuilderTest < ActiveSupport::TestCase
  describe '#parenthesize' do
    test 'returns empty string for blank input' do
      assert_equal '', QueryBuilder.parenthesize('')
      assert_nil QueryBuilder.parenthesize(nil)
      assert_equal '   ', QueryBuilder.parenthesize('   ')
    end

    test 'returns same string if already parenthesized and always=false' do
      assert_equal '(already parenthesized)', QueryBuilder.parenthesize('(already parenthesized)')
      assert_equal '(test)', QueryBuilder.parenthesize('(test)')
    end

    test 'adds parentheses to non-parenthesized string' do
      assert_equal '(test)', QueryBuilder.parenthesize('test')
      assert_equal '(name = value)', QueryBuilder.parenthesize('name = value')
    end

    test 'adds parentheses when always=true even if already parenthesized' do
      assert_equal '((already parenthesized))', QueryBuilder.parenthesize('(already parenthesized)', always: true)
      assert_equal '(test)', QueryBuilder.parenthesize('test', always: true)
    end

    test 'handles strings that start with ( but do not end with )' do
      assert_equal '((incomplete)', QueryBuilder.parenthesize('(incomplete')
      assert_equal '(incomplete))', QueryBuilder.parenthesize('incomplete)')
    end
  end

  describe '#join' do
    test 'returns nil for empty array' do
      assert_nil QueryBuilder.join('AND', [])
      assert_nil QueryBuilder.join('OR', [])
    end

    test 'returns nil when all parts are blank' do
      assert_nil QueryBuilder.join('AND', ['', nil, '   '])
    end

    test 'returns single part with parentheses when only one non-blank part' do
      assert_equal '(test)', QueryBuilder.join('AND', ['test'])
      assert_equal '(single)', QueryBuilder.join('OR', ['', 'single', nil])
    end

    test 'joins multiple parts with a conjunction' do
      result = QueryBuilder.join('AND', ['name = value', 'status = active', 'foo ~ bar*'])
      assert_equal '((name = value) AND (status = active) AND (foo ~ bar*))', result
    end

    test 'filters out blank parts and joins remaining' do
      result = QueryBuilder.join('AND', ['name = value', '', 'status = active', nil, ''])
      assert_equal '((name = value) AND (status = active))', result
    end

    test 'handles already parenthesized parts' do
      result = QueryBuilder.join('AND', ['(name = value)', '(status = active)'])
      assert_equal '((name = value) AND (status = active))', result
    end
  end

  describe '#key_value_in' do
    test 'returns formatted string for non-empty values array' do
      result = QueryBuilder.key_value_in('organization_id', [1, 2, 3])
      assert_equal 'organization_id ^ (1,2,3)', result
    end

    test 'returns formatted string for single value' do
      result = QueryBuilder.key_value_in('user_id', [42])
      assert_equal 'user_id ^ (42)', result
    end

    test 'returns formatted string for string values' do
      result = QueryBuilder.key_value_in('name', ['admin', 'user'])
      assert_equal 'name ^ (admin,user)', result
    end

    test 'returns nil for empty array when on_empty is :nil (default)' do
      assert_nil QueryBuilder.key_value_in('organization_id', [])
      assert_nil QueryBuilder.key_value_in('organization_id', [], :nil)
    end

    test 'returns blocking condition for empty array when on_empty is :block' do
      result = QueryBuilder.key_value_in('organization_id', [], :block)
      assert_equal '(set? organization_id AND null? organization_id)', result
    end

    test 'raises ArgumentError for invalid on_empty value' do
      assert_raises ArgumentError do
        QueryBuilder.key_value_in('organization_id', [], :invalid)
      end
    end

    test 'handles mixed type values' do
      result = QueryBuilder.key_value_in('mixed', [1, 'string', :symbol])
      assert_equal 'mixed ^ (1,string,symbol)', result
    end
  end
end
