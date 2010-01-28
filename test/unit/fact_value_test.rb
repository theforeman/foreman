require 'test_helper'

class FactValueTest < ActiveSupport::TestCase
  def setup
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
                        :domain => Domain.find_or_create_by_name("company.com"),
                        :operatingsystem => Operatingsystem.create(:name => "linux", :major => 389),
                        :architecture => Architecture.find_or_create_by_name("i386"),
                        :environment => Environment.find_or_create_by_name("envy"),
                        :disk => "empty partition"

    @fact_name = Puppet::Rails::FactName.create(:name => "my_facting_name")
    @fact_value = FactValue.create(:value => "some value", :host => host, :fact_name => @fact_name)
  end

#  test "should return the memory average" do
#    p FactValue.mem_average("my_facting_name")
#  end

  test "should return the count of each fact" do
    h = {"Some value"=>1}
    assert_equal h, FactValue.count_each("my_facting_name")

    #Now creating a new fact value
    other_host = Host.create :name => "myfullhost2", :mac => "aabbccddeeff", :ip => "123.05.02.03",
                              :domain => Domain.find_or_create_by_name("company.com"),
                              :operatingsystem => Operatingsystem.create(:name => "linux", :major => 389),
                              :architecture => Architecture.find_or_create_by_name("i386"),
                              :environment => Environment.find_or_create_by_name("envy"),
                              :disk => "empty partition"
    other_fact_value = FactValue.create(:value => "some value", :host => other_host, :fact_name => @fact_name)
    h["Some value"] = 2
    assert_equal h, FactValue.count_each("my_facting_name")
  end
end

