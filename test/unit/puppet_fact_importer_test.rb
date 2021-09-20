require 'test_helper'

class PuppetFactImporterTest < ActiveSupport::TestCase
  include FactImporterIsolation

  attr_reader :host, :importer
  setup do
    @host = FactoryBot.create(:host)
    FactoryBot.build(:fact_value, :value => '2.6.9', :host => @host,
                       :fact_name => FactoryBot.create(:fact_name, :name => 'kernelversion'))
    FactoryBot.build(:fact_value, :value => '10.0.19.33', :host => @host,
                       :fact_name => FactoryBot.create(:fact_name, :name => 'ipaddress'))
  end

  test 'importer imports everything as strings' do
    import 'kernelversion' => '2.6.9', 'vda_size' => 4242
    assert_equal '2.6.9', value('kernelversion')
    assert_equal '4242', value('vda_size')
  end

  test 'importer imports structured facts' do
    import({"system_uptime" => {"seconds" => 14911897, "hours" => 4142, "days" => 172, "uptime" => "172 days"}})
    assert_nil value('system_uptime')
    assert_equal '172 days', value('system_uptime::uptime')
  end

  def import(facts)
    @importer = FactImporters::Structured.new(@host, nil, facts)
    allow_transactions_for @importer
    importer.import!
  end

  def value(fact)
    FactValue.joins(:fact_name).where(:host_id => @host.id, :fact_names => { :name => fact }).first.try(:value)
  end
end
