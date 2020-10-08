require 'integration_test_helper'

class ChildFactValueIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @host = FactoryBot.create(:host)
    @parent_name = FactoryBot.create(:fact_name, name: 'test/test', compose: true)
    @parent_value = FactoryBot.create(:fact_value, :value => nil, :host => @host, :fact_name => @parent_name)

    @child_suffix = 'child'
    @child_name = FactoryBot.create(:fact_name, :name => "#{@parent_name.name}::#{@child_suffix}", :short_name => @child_suffix, :ancestry => @parent_name.id)
    @child_value = FactoryBot.create(:fact_value, :host => @host, :fact_name => @child_name)
  end

  test "parent name links to child list" do
    visit fact_values_path
    assert page.has_link? @parent_name.name

    # click on the parent name link
    within(:xpath, "//tr[contains(.,'#{@parent_name.name}')]") do
      assert_equal "Show all #{@parent_name.name} children fact values", first(:xpath, "//td[2]//li[1]//a[2]")[:title]
      first(:xpath, "//td[2]//a[1]").click
    end

    # click on the child name link
    within(:xpath, "//tr[contains(.,'#{@child_name.short_name}')]") do
      assert_equal "Show #{@child_name.name} fact values for all hosts", first(:xpath, "//td[1]//a")[:title]
      first(:xpath, "//td[1]//a").click
    end

    assert_equal "Show all #{@parent_name.name} children fact values", first(:xpath, "//td[2]//a")[:title]
  end
end
