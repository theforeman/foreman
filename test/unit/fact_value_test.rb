require 'test_helper'

class FactValueTest < ActiveSupport::TestCase
  def setup
    @host = FactoryGirl.create(:host)
    @fact_name   = FactName.create(:name => "my_facting_name")
    @fact_value  = FactValue.create(:value => "some value", :host => @host, :fact_name => @fact_name)
    @child_name  = FactName.create(:name => 'my_facting_name::child', :parent => @fact_name)
    @child_value = FactValue.create(:value => 'child value', :host => @host, :fact_name => @child_name)
    @fact_name.save; @fact_value.save; @child_name.save; @child_value.save
  end

  test "should return the count of each fact" do
    h = [{:label=>"some value", :data=>1}]
    assert_equal h, FactValue.count_each("my_facting_name")

    #Now creating a new fact value
    @other_host = FactoryGirl.create(:host)
    other_fact_value = FactValue.create(:value => "some value", :host => @other_host, :fact_name => @fact_name)
    h = [{:label=>"some value", :data=>2}]
    assert_equal h, FactValue.count_each("my_facting_name")
  end

  test "should fail validation when the host already has a fact with the same name" do
    assert !FactValue.new(:value => "some value", :host => @host, :fact_name => @fact_name).valid?
  end

  test '.root_only scope returns only roots' do
    result = FactValue.root_only
    assert_includes result, @fact_value
    assert_not_include result, @child_value
  end

  test '.with_fact_parent_id scope returns only children for given id' do
    result = FactValue.with_fact_parent_id(@fact_name.id)
    assert_equal [ @child_value ], result

    result = FactValue.with_fact_parent_id(@child_name.id)
    assert_equal [], result
  end

  test "should return search results if search free text is fact name" do
    FactoryGirl.create(:fact_value, :value => '2.6.9',:host => FactoryGirl.create(:host),
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'kernelversion'))
    results = FactValue.search_for('kernelversion')
    assert_equal 1, results.count
    assert_equal 'kernelversion', results.first.name
  end

  test "should return search results for name = fact name" do
    FactoryGirl.create(:fact_value, :value => '2.6.9',:host => FactoryGirl.create(:host),
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'kernelversion'))
    results = FactValue.search_for('name = kernelversion')
    assert_equal 1, results.count
    assert_equal 'kernelversion', results.first.name
  end

  test 'should return search results for host = fqdn' do
    host = FactoryGirl.create(:host)
    FactoryGirl.create(:fact_value, :value => '2.6.9',:host => host,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'kernelversion'))
    results = FactValue.search_for("host = #{host.fqdn}")
    refute_empty results
  end

  test 'should return empty search results for host with no facts' do
    host = FactoryGirl.create(:host)
    results = FactValue.search_for("host = #{host.fqdn}")
    assert_empty results
  end

end

