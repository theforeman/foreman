require 'integration_test_helper'

class FactValueJSTest < IntegrationTestWithJavascript
  def setup
    @host = FactoryBot.create(:host)
    @fact_name = FactoryBot.create(:fact_name)
    @value = FactoryBot.create(:fact_value, :host => @host, :fact_name => @fact_name)
  end
  test "index page" do
    assert_index_page(fact_values_path, "Fact Values", nil, true)
  end
  test "host fact links" do
    visit fact_values_path
    within(:xpath, "//tr[contains(.,'#{@fact_name.name}')]") do
      click_link(@host.fqdn)
    end
    has_selector?(".rbt-input-main", text: "host = #{@host.fqdn}", wait: 3)
    assert_equal "host = #{@host.fqdn}", find('.rbt-input-main').value
  end
  test "fact_name fact links" do
    visit fact_values_path
    find(:xpath, "//tr[contains(.,'#{@fact_name.name}')]//td[2]//a").click
    has_selector?(".rbt-input-main", text: "name = #{@fact_name.name}", wait: 3)
    assert_equal "name = #{@fact_name.name}", find('.rbt-input-main').value
  end
  test "value fact links" do
    visit fact_values_path
    click_link(@value.value)
    has_selector?(".rbt-input-main", text: "facts.#{@fact_name.name} = \"#{@value.value}\"", wait: 3)
    assert_equal "facts.#{@fact_name.name} = \"#{@value.value}\"", find('.rbt-input-main').value
  end
end
