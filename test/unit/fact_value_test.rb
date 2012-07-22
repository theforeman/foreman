require 'test_helper'

class FactValueTest < ActiveSupport::TestCase
  def setup
    @host = hosts(:one)
    @fact_name  = FactName.create(:name => "my_facting_name")
    @fact_value = FactValue.create(:value => "some value", :host => @host, :fact_name => @fact_name)
  end

#  test "should return the memory average" do
#    p FactValue.mem_average("my_facting_name")
#  end

  test "should return the count of each fact" do
    h = {"some value"=>1}
    assert_equal h, FactValue.count_each("my_facting_name")

    #Now creating a new fact value
    @other_host = hosts(:two)
    other_fact_value = FactValue.create(:value => "some value", :host => @other_host, :fact_name => @fact_name)
    h["some value"] = 2
    assert_equal h, FactValue.count_each("my_facting_name")
  end
end

