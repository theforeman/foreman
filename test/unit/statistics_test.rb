require "test_helper"

class StatisticsTest < ActiveSupport::TestCase
  def setup
    User.current = users :admin
  end

  test 'it should return list of statistics objects' do
    assert Statistics.charts
  end

  test 'it should include an Operating System stat' do
    os = Statistics.charts.detect {|s| s.id == 'operatingsystem'}
    assert_equal "operatingsystem", os.id
    data = { :id=>"operatingsystem", :title=>"OS Distribution", :url=>"statistics/operatingsystem", :search=>"os_title=~VAL~" }
    assert_equal data, os.metadata
  end

  test 'it should initialize a base statistics object' do
    stat = Statistics::Base.new(:count_by => :hostgroup)
    assert_equal :hostgroup, stat.count_by
    assert_equal 'hostgroup', stat.id
    assert_equal 'statistics/hostgroup', stat.url
    assert_raise(NotImplementedError) { stat.calculate }
  end

  test 'it should initialize a fact counter statistics object' do
    stat = Statistics::CountFacts.new(:count_by => 'uptime')
    assert_kind_of Array, stat.calculate
  end

  test 'it should initialize a fact counter statistics object with units' do
    stat = Statistics::CountFacts.new(:count_by => 'uptime', :unit => ['%s core', '%s cores'])
    assert_equal ['%s core', '%s cores'], stat.unit
    assert_kind_of Array, stat.calculate
  end

  test 'it should initialize a host counter statistics object' do
    stat = Statistics::CountHosts.new(:count_by => :compute_resource)
    assert_kind_of Array, stat.calculate
  end

  test 'it should fail to calculate a puppet class counter statistics object without an id' do
    assert_raise(ArgumentError) { Statistics::CountPuppetClasses.new() }
  end

  test 'it should initialize a puppet class counter statistics object' do
    stat = Statistics::CountPuppetClasses.new(:id => :classes)
    assert_equal 'statistics/classes',stat.url
    assert_kind_of Array, stat.calculate
  end

  test 'it should fail to calculate a Fact class counter statistics object without count_by' do
    assert_raise(ArgumentError) { Statistics::CountNumericalFactPair.new() }
  end

  test 'it should initialize a fact pair counter statistics object' do
    stat = Statistics::CountNumericalFactPair.new(:count_by => :memory)
    assert_equal 'memorysize', stat.send(:total_name)
    assert_equal 'memoryfree', stat.send(:used_name)
    calc = stat.calculate
    assert_kind_of Array, calc
    assert_equal 'free memory', calc[0][:label]
    assert_equal 'used memory', calc[1][:label]
  end
end
