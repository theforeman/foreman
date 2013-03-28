require 'test_helper'

class FactValueTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "index page" do
    assert_index_page(fact_values_path,"Fact Values",nil,true)
  end

  test "host fact links" do
    visit fact_values_path
    within(:xpath, "//tr[contains(.,'kernelversion')]") do
      click_link("my5name.mydomain.net")
    end
    assert_equal 'host = my5name.mydomain.net', find_field('search').value
  end

  test "fact_name fact links" do
    visit fact_values_path
    within(:xpath, "//tr[contains(.,'ipaddress')]") do
      #first("ipaddress").click  #click_link returns ambigous
      first(:xpath, "//td[2]/a[2]").click
    end
    assert_equal 'name = ipaddress', find_field('search').value
  end

  test "value fact links" do
    visit fact_values_path
    click_link("2.6.9")
    assert_equal 'facts.kernelversion = "2.6.9"', find_field('search').value
  end

end
