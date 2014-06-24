require 'test_helper'

class FactValueTest < ActiveSupport::TestCase
  def setup
    @host = hosts(:one)
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
    @other_host = hosts(:two)
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
    results = FactValue.search_for('kernelversion')
    assert_equal 1, results.count
    assert_equal 'kernelversion', results.first.name
  end

  test "should return search results for name = fact name" do
    results = FactValue.search_for('name = kernelversion')
    assert_equal 1, results.count
    assert_equal 'kernelversion', results.first.name
  end

end

