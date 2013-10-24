require 'test_helper'

class HostTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = User.find_by_login "admin"
    @host = hosts(:one)

  end

  test "merge_facts adds new facts" do
    PuppetFactImporter.new(@host, {'foo' => 'bar', 'kernelversion' => '2.6.9', 'ipaddress' => '10.0.19.33'}).merge_facts
    assert_equal 'bar', (@host.fact_values.index_by(&:name))['foo'].value
  end

  test "merge_facts removes deleted facts" do
    PuppetFactImporter.new(@host, {'ipaddress' => '10.0.19.33'}).merge_facts
    assert !(@host.fact_values.index_by(&:name)).include?('kernelversion')
  end

  test "merge_facts updates fact values" do
    PuppetFactImporter.new(@host, {'kernelversion' => '3.8.11', 'ipaddress' => '10.0.19.33'}).merge_facts
    assert_equal '3.8.11', @host.fact_values.index_by(&:name)['kernelversion'].value
  end

  test "merge_facts shouldn't set nil values" do
    PuppetFactImporter.new(@host, {'kernelversion' => nil, 'ipaddress' => '10.0.19.33'}).merge_facts
    assert !(@host.fact_values.index_by(&:name)).include?('kernelversion')
  end
end
