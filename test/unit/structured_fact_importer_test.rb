require 'test_helper'
require 'fact_importer_test_helper'

class StructuredFactImporterTest < ActiveSupport::TestCase
  include FactImporterIsolation

  attr_reader :importer

  let(:host) { FactoryBot.create(:host) }

  describe '#import!' do
    test 'hash facts are imported' do
      import 'structured' => {'one' => 'value', 'two' => {'two-deep' => 'nested'}}
      assert_nil value('structured')
      assert_equal 'value', value('structured::one')
      assert_equal 'nested', value('structured::two::two-deep')
    end

    test 'creates compose (parent) facts' do
      import 'structured' => {'one' => {'two' => 'value'}}

      assert fact_value('structured').compose
      assert_nil value('structured')
      assert_nil fact_value('structured').fact_name.parent

      assert fact_value('structured::one').compose
      assert_nil value('structured::one')
      assert_equal fact_value('structured').fact_name, fact_value('structured::one').fact_name.parent

      refute fact_value('structured::one::two').compose
      assert_equal 'value', value('structured::one::two')
      assert_equal fact_value('structured::one').fact_name, fact_value('structured::one::two').fact_name.parent
    end

    test 'updates fact values within hashes' do
      import 'structured' => {'one' => 'value'}
      assert_equal 'value', value('structured::one')
      import 'structured' => {'one' => 'changed'}
      assert_equal 'changed', value('structured::one')

      assert_equal 0, importer.counters[:deleted]
      assert_equal 1, importer.counters[:updated]
      assert_equal 0, importer.counters[:added]
    end

    test 'enables compose attribute of previously string facts' do
      import 'structured' => 'value'
      refute fact_value('structured').compose
      assert_equal 'value', value('structured')

      import 'structured' => {'one' => 'value'}
      assert fact_value('structured').compose
      assert_nil value('structured')
    end
  end

  describe 'normalize' do
    test 'has no effect on unstructured facts' do
      importer = StructuredFactImporter.new(nil, 'a' => 'b')
      assert_equal({'a' => 'b'}, importer.send(:facts))
    end

    test 'removes nil fact values' do
      importer = StructuredFactImporter.new(nil, 'a' => nil)
      assert_equal({}, importer.send(:facts))
    end

    test 'changes symbol keys to strings' do
      importer = StructuredFactImporter.new(nil, :a => 'b')
      assert_equal({'a' => 'b'}, importer.send(:facts))
    end

    test 'expands nested hash keys with separators' do
      importer = StructuredFactImporter.new(nil, 'a' => {'b' => 'c'})
      assert_equal({'a' => nil, 'a::b' => 'c'}, importer.send(:facts))
    end

    test 'changes non-string values to strings' do
      importer = StructuredFactImporter.new(nil, :a => 1)
      assert_equal({'a' => '1'}, importer.send(:facts))
    end

    test 'subtrees excluded properly' do
      data = FactsData::HierarchicalPuppetStyleFacts.new
      Setting.stubs(:[]).with(:excluded_facts).returns(data.filter)

      facts = data.good_facts.deep_merge(data.ignored_facts)

      importer = StructuredFactImporter.new(nil, facts)
      actual_facts = importer.send(:facts)

      assert_equal data.flat_result, actual_facts
    end
  end

  def import(facts)
    @importer = StructuredFactImporter.new(host, facts)
    @importer.stubs(:fact_name_class).returns(FactName)
    allow_transactions_for @importer
    @importer.import!
  end

  def fact_value(fact)
    FactValue.joins(:fact_name).where(:host_id => host.id, :fact_names => { :name => fact }).first
  end

  def value(fact)
    fact_value(fact).try(:value)
  end
end
