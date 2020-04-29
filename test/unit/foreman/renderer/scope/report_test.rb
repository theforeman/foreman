require 'test_helper'

class ReportScopeTest < ActiveSupport::TestCase
  setup do
    source = Foreman::Renderer::Source::String.new(content: '')
    @scope = Foreman::Renderer::Scope::Report.new(source: source)
  end

  describe '#report_render' do
    test 'render headers' do
      @scope.report_row('Col1': 'Val1', 'Col2': 'Val2')
      @scope.report_row('Col3': 'Val3', 'Col4': 'Val4')
      expected_csv = "Col1,Col2\nVal1,Val2\nVal3,Val4\n"
      assert_equal expected_csv, @scope.report_render(format: :csv)

      expected_yaml = <<~OUT
        ---
        - Col1: Val1
          Col2: Val2
        - Col1: Val3
          Col2: Val4
      OUT
      assert_equal expected_yaml, @scope.report_render(format: :yaml)
    end

    test 'render report ordering' do
      @scope.report_row(name: 'c', value: 1)
      @scope.report_row(name: 'a', value: 3)
      @scope.report_row(name: 'b', value: 22)
      @scope.report_row(name: 'e', value: 0)
      @scope.report_row(name: 'd', value: 5)

      expected_csv = "name,value\na,3\nb,22\nc,1\nd,5\ne,0\n"
      assert_equal expected_csv, @scope.report_render(format: :csv, order: 'name')
      assert_equal expected_csv, @scope.report_render(format: :csv, order: :name)
      assert_equal expected_csv, @scope.report_render(format: :csv, order: ['name'])
      assert_equal expected_csv, @scope.report_render(format: :csv, order: ['name', 'value'])

      expected_csv = "name,value\ne,0\nc,1\na,3\nd,5\nb,22\n"
      assert_equal expected_csv, @scope.report_render(format: :csv, order: 'value')

      expected_csv = "name,value\ne,0\nd,5\nc,1\nb,22\na,3\n"
      assert_equal expected_csv, @scope.report_render(format: :csv, order: 'name', reverse_order: true)

      @scope.report_row(name: 'a', value: 2)
      @scope.report_row(name: 'b', value: 2)
      expected_csv = "name,value\na,2\na,3\nb,2\nb,22\nc,1\nd,5\ne,0\n"
      assert_equal expected_csv, @scope.report_render(format: :csv, order: ['name', 'value'])
    end

    test 'empty report' do
      expected_csv = "\n"
      assert_equal expected_csv, @scope.report_render(format: :csv)

      expected_yaml = <<~OUT
        --- []
      OUT
      assert_equal expected_yaml, @scope.report_render(format: :yaml)
    end

    test 'render types' do
      @scope.report_row(
        'List': ['Val1', 1, true],
        'String': 'Text',
        'Number': 1,
        'Bool': false,
        'Empty': '',
        'Nil': nil
      )
      expected_csv = "List,String,Number,Bool,Empty,Nil\n\"Val1,1,true\",Text,1,false,\"\",\"\"\n"
      assert_equal expected_csv, @scope.report_render(format: :csv)

      expected_yaml = <<~OUT + "  Nil: \n"
        ---
        - List:
          - Val1
          - 1
          - true
          String: Text
          Number: 1
          Bool: false
          Empty: ''
      OUT
      assert_equal expected_yaml, @scope.report_render(format: :yaml)
    end
  end
end
