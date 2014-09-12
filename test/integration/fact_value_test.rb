require 'test_helper'

class FactValueTest < ActionDispatch::IntegrationTest

  def setup
    @host = FactoryGirl.create(:host)
    FactoryGirl.create(:fact_value, :value => '2.6.9',:host => @host,
                       :fact_name => FactoryGirl.create(:fact_name, :name => 'kernelversion'))
  end


  test "index page" do
    assert_index_page(fact_values_path,"Fact Values",nil,true)
  end

  test "host fact links" do
    visit fact_values_path
    within(:xpath, "//tr[contains(.,'kernelversion')]") do
      click_link(@host.fqdn)
    end
    assert_equal "host = #{@host.fqdn}", find_field('search').value
  end

  test "fact_name fact links" do
    visit fact_values_path
    within(:xpath, "//tr[contains(.,'kernelversion')]") do
      first(:xpath, "//td[2]/a").click
    end
    assert_equal 'name = kernelversion', find_field('search').value
  end

  test "value fact links" do
    visit fact_values_path
    click_link("2.6.9")
    assert_equal 'facts.kernelversion = "2.6.9"', find_field('search').value
  end

end
