require 'test_helper'
require 'fact_importer_test_helper'

class FactImporterTest < ActiveSupport::TestCase
  include FactImporterIsolation

  attr_reader :importer
  class CustomFactName < FactName; end
  class CustomImporter < FactImporter
    def fact_name_class
      CustomFactName
    end
  end

  let(:host) { FactoryBot.create(:host) }
  let(:fact_importer_registry) { Foreman::Plugin.fact_importer_registry }

  test "default importers" do
    assert_includes fact_importer_registry.importers.keys, 'puppet'
    assert_equal PuppetFactImporter, fact_importer_registry.get(:puppet)
    assert_equal PuppetFactImporter, fact_importer_registry.get('puppet')
    assert_equal PuppetFactImporter, fact_importer_registry.get(:whatever)
    assert_equal PuppetFactImporter, fact_importer_registry.get('whatever')
  end

  test 'importer API defines background processing support' do
    assert FactImporter.respond_to?(:support_background)
  end

  context 'when using a custom importer' do
    setup do
      fact_importer_registry.register :custom_importer, CustomImporter
    end

    test ".register_custom_importer" do
      assert_equal CustomImporter, fact_importer_registry.get(:custom_importer)
    end

    test 'importers without authorized_smart_proxy_features return empty set of features' do
      assert_equal [], fact_importer_registry.get(:custom_importer).authorized_smart_proxy_features
    end

    context 'importing facts' do
      test 'facts of other type do not collide even if they inherit from FactName' do
        assert_nothing_raised do
          custom_import '_timestamp' => '234'
          puppet_import '_timestamp' => '345'
        end
      end

      test 'facts created have the origin attribute set' do
        custom_import('foo' => 'bar')
        imported_fact = FactName.find_by_name('foo').fact_values.first
        assert_equal 'N/A', imported_fact.origin
      end
    end
  end

  describe '#normalize' do
    test 'filters regular facts' do
      data = FactsData::FlatFacts.new
      Setting.stubs(:[]).with(:excluded_facts).returns(data.filter)

      facts = data.good_facts.merge(data.ignored_facts)

      importer = FactImporter.new(nil, facts)
      actual_facts = importer.send(:facts)

      assert_equal data.good_facts, actual_facts
    end

    test 'filters a::b facts' do
      data = FactsData::RhsmStyleFacts.new
      Setting.stubs(:[]).with(:excluded_facts).returns(data.filter)

      facts = data.good_facts.merge(data.ignored_facts)

      importer = FactImporter.new(nil, facts)
      actual_facts = importer.send(:facts)

      assert_equal data.good_facts, actual_facts
    end

    test 'filters macaddress_virbr0 facts' do
      data = FactsData::FlatPuppetStyleFacts.new
      Setting.stubs(:[]).with(:excluded_facts).returns(data.filter)

      facts = data.good_facts.merge(data.ignored_facts)

      importer = FactImporter.new(nil, facts)
      actual_facts = importer.send(:facts)

      assert_equal data.good_facts, actual_facts
    end

    test 'filters default interface facts' do
      data = FactsData::DefaultInterfacesFacts.new

      facts = data.good_facts.merge(data.ignored_facts)

      importer = FactImporter.new(nil, facts)
      actual_facts = importer.send(:facts)

      assert_equal data.good_facts, actual_facts
    end
  end

  describe '#import!' do
    setup do
      FactoryBot.create(:fact_value, :value => '2.6.9', :host => host,
                         :fact_name => FactoryBot.create(:fact_name, :name => 'kernelversion'))
      FactoryBot.create(:fact_value, :value => '10.0.19.33', :host => host,
                         :fact_name => FactoryBot.create(:fact_name, :name => 'ipaddress'))
    end

    test 'importer imports everything as strings' do
      default_import 'kernelversion' => '2.6.9', 'vda_size' => 4242, 'structured' => {'key' => 'value'}
      assert_equal '2.6.9', value('kernelversion')
      assert_equal '4242', value('vda_size')
      assert_equal '{"key"=>"value"}', value('structured')
      refute FactName.find_by_name('structured').compose?
    end

    test 'importer adds new facts' do
      assert_equal '2.6.9', value('kernelversion')
      assert_equal '10.0.19.33', value('ipaddress')
      default_import 'foo' => 'bar', 'kernelversion' => '2.6.9', 'ipaddress' => '10.0.19.33'
      assert_equal 'bar', value('foo')
      assert_equal '2.6.9', value('kernelversion')
      assert_equal 0, importer.counters[:deleted]
      assert_equal 0, importer.counters[:updated]
      assert_equal 1, importer.counters[:added]
    end

    test 'importer removes deleted facts' do
      default_import 'ipaddress' => '10.0.19.33'
      assert_nil value('kernelversion')

      assert_equal 1, importer.counters[:deleted]
      assert_equal 0, importer.counters[:updated]
      assert_equal 0, importer.counters[:added]
    end

    test 'importer updates fact values' do
      assert_equal '2.6.9', value('kernelversion')
      assert_equal '10.0.19.33', value('ipaddress')
      default_import 'kernelversion' => '3.8.11', 'ipaddress' => '10.0.19.33'
      assert_equal '3.8.11', value('kernelversion')

      assert_equal 0, importer.counters[:deleted]
      assert_equal 1, importer.counters[:updated]
      assert_equal 0, importer.counters[:added]
    end

    test "importer shouldn't set nil values" do
      assert_equal '2.6.9', value('kernelversion')
      assert_equal '10.0.19.33', value('ipaddress')
      default_import('kernelversion' => nil, 'ipaddress' => '10.0.19.33')
      assert_nil value('kernelversion')
      assert_equal '10.0.19.33', value('ipaddress')

      assert_equal 1, importer.counters[:deleted]
      assert_equal 0, importer.counters[:updated]
      assert_equal 0, importer.counters[:added]
    end

    test "importer adds, removes and deletes facts" do
      assert_equal '2.6.9', value('kernelversion')
      assert_equal '10.0.19.33', value('ipaddress')
      default_import('kernelversion' => nil, 'ipaddress' => '10.0.19.5', 'uptime' => '1 picosecond')
      assert_nil value('kernelversion')
      assert_equal '10.0.19.5', value('ipaddress')
      assert_equal '1 picosecond', value('uptime')

      assert_equal 1, importer.counters[:deleted]
      assert_equal 1, importer.counters[:updated]
      assert_equal 1, importer.counters[:added]
    end

    test "importer retains 'other' facts" do
      assert_equal '2.6.9', value('kernelversion')
      FactoryBot.create(:fact_value, :value => 'othervalue', :host => host,
                         :fact_name => FactoryBot.create(:fact_name_other, :name => 'otherfact'))
      default_import('ipaddress' => '10.0.19.5', 'uptime' => '1 picosecond')
      assert_equal 'othervalue', value('otherfact')
      assert_nil value('kernelversion')
      assert_equal '10.0.19.5', value('ipaddress')
      assert_equal '1 picosecond', value('uptime')
      assert_equal 1, importer.counters[:deleted]
      assert_equal 1, importer.counters[:updated]
      assert_equal 1, importer.counters[:added]
    end

    test "importer handles fact name additions" do
      facts = { 'duplicate_name' => 'some_value' }
      importer = FactImporter.new(host, facts)
      importer.stubs(:fact_name_class).returns(FactName)
      allow_transactions_for importer
      importer.stubs(:save_name_record).raises(ActiveRecord::RecordNotUnique, 'Test message')

      # redefine fact_name_attributes for this instance, so it will create
      # the fact name before it's actually created by the importer
      def importer.fact_name_attributes(fact_name)
        ActiveRecord::Base.transaction(:requires_new => true) do
          dup_record = FactoryBot.build(:fact_name, :name => fact_name)
          # save duplicate record in isolated transaction
          dup_record.save!
        end

        {
          name: fact_name,
        }
      end

      importer.import!

      name_record = FactName.find_by(name: 'duplicate_name')
      assert_not_nil name_record
    end

    test 'importer cannot run in transaction' do
      facts = { 'some_name' => 'some_value' }
      importer = FactImporter.new(host, facts)
      importer.stubs(:fact_name_class).returns(FactName)
      exception = assert_raises(RuntimeError) do
        importer.import!
      end
      assert_match(/outside of global transaction/, exception.message)
    end
  end

  def default_import(facts)
    @importer = FactImporter.new(host, facts)
    allow_transactions_for @importer
    @importer.stubs(:fact_name_class).returns(FactName)
    @importer.import!
  end

  def custom_import(facts)
    @importer = CustomImporter.new(host, facts)
    allow_transactions_for @importer
    @importer.import!
  end

  def puppet_import(facts)
    @importer = PuppetFactImporter.new(host, facts)
    allow_transactions_for @importer
    @importer.import!
  end

  def value(fact)
    FactValue.joins(:fact_name).where(:host_id => host.id, :fact_names => { :name => fact }).first.try(:value)
  end
end
