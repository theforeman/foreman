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
