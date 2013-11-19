require 'test_helper'

class FactValueTest < ActiveSupport::TestCase
  def setup
    @system = systems(:one)
    @fact_name  = FactName.create(:name => "my_facting_name")
    @fact_value = FactValue.create(:value => "some value", :system => @system, :fact_name => @fact_name)
  end

  test "should return the count of each fact" do
    h = [{:label=>"some value", :data=>1}]
    assert_equal h, FactValue.count_each("my_facting_name")

    #Now creating a new fact value
    @other_system = systems(:two)
    other_fact_value = FactValue.create(:value => "some value", :system => @other_system, :fact_name => @fact_name)
    h = [{:label=>"some value", :data=>2}]
    assert_equal h, FactValue.count_each("my_facting_name")
  end

  test "should fail validation when the system already has a fact with the same name" do
    assert !FactValue.new(:value => "some value", :system => @system, :fact_name => @fact_name).valid?
  end
end

