require 'test_helper'

class FactValueTest < ActionDispatch::IntegrationTest
  def setup
    @host = FactoryGirl.create(:host)
    @fact_name = FactoryGirl.create(:fact_name)
    @value = FactoryGirl.create(:fact_value, :host => @host,
                       :fact_name => @fact_name)
  end

  test "index page" do
    assert_index_page(fact_values_path,"Fact Values",nil,true)
  end

  test "host fact links" do
    visit fact_values_path
    within(:xpath, "//tr[contains(.,'#{@fact_name.name}')]") do
      click_link(@host.fqdn)
    end
    assert_equal "host = #{@host.fqdn}", find_field('search').value
  end

  test "fact_name fact links" do
    skip
    visit fact_values_path
    within(:xpath, "//tr[contains(.,'#{@fact_name.name}')]") do
      first(:xpath, "//td[2]/a").click
    end
    assert_equal "name = #{@fact_name.name}", find_field('search').value
  end

  test "value fact links" do
    visit fact_values_path
    click_link(@value.value)
    assert_equal "facts.#{@fact_name.name} = \"#{@value.value}\"", find_field('search').value
  end
end
