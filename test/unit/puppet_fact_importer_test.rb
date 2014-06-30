require 'test_helper'

class PuppetFactImporterTest < ActiveSupport::TestCase
  attr_reader :host, :importer
  setup do
    disable_orchestration
    User.current = users :admin
    @host        = hosts(:one)
  end

  test 'importer adds new facts' do
    assert_equal '2.6.9', value('kernelversion')
    assert_equal '10.0.19.33', value('ipaddress')
    import 'foo' => 'bar', 'kernelversion' => '2.6.9', 'ipaddress' => '10.0.19.33'
    assert_equal 'bar', value('foo')
    assert_equal '2.6.9', value('kernelversion')
    assert_equal 0, importer.counters[:deleted]
    assert_equal 0, importer.counters[:updated]
    assert_equal 1, importer.counters[:added]
  end

  test 'importer removes deleted facts' do
    import 'ipaddress' => '10.0.19.33'
    assert_nil value('kernelversion')

    assert_equal 1, importer.counters[:deleted]
    assert_equal 0, importer.counters[:updated]
    assert_equal 0, importer.counters[:added]
  end

  test 'importer updates fact values' do
    assert_equal '2.6.9', value('kernelversion')
    assert_equal '10.0.19.33', value('ipaddress')
    import 'kernelversion' => '3.8.11', 'ipaddress' => '10.0.19.33'
    assert_equal '3.8.11', value('kernelversion')

    assert_equal 0, importer.counters[:deleted]
    assert_equal 1, importer.counters[:updated]
    assert_equal 0, importer.counters[:added]
  end

  test "importer shouldn't set nil values" do
    assert_equal '2.6.9', value('kernelversion')
    assert_equal '10.0.19.33', value('ipaddress')
    import('kernelversion' => nil, 'ipaddress' => '10.0.19.33')
    assert_nil value('kernelversion')
    assert_equal '10.0.19.33', value('ipaddress')

    assert_equal 1, importer.counters[:deleted]
    assert_equal 0, importer.counters[:updated]
    assert_equal 0, importer.counters[:added]
  end

  test "importer adds, removes and deletes facts" do
    assert_equal '2.6.9', value('kernelversion')
    assert_equal '10.0.19.33', value('ipaddress')
    import('kernelversion' => nil, 'ipaddress' => '10.0.19.5', 'uptime' => '1 picosecond')
    assert_nil value('kernelversion')
    assert_equal '10.0.19.5', value('ipaddress')
    assert_equal '1 picosecond', value('uptime')

    assert_equal 1, importer.counters[:deleted]
    assert_equal 1, importer.counters[:updated]
    assert_equal 1, importer.counters[:added]
  end

  def import(facts)
    @importer = PuppetFactImporter.new(@host, facts)
    importer.import!
  end

  def value fact
    FactValue.joins(:fact_name).where(:host_id => @host.id, :fact_names => { :name => fact }).first.try(:value)
  end
end
