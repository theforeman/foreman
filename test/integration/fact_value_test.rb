require 'integration_test_helper'

class FactValueIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @host = FactoryGirl.create(:host)
    @fact_name = FactoryGirl.create(:fact_name)
    @value = FactoryGirl.create(:fact_value, :host => @host, :fact_name => @fact_name)
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
    visit fact_values_path
    find(:xpath, "//tr[contains(.,'#{@fact_name.name}')]//td[2]//a").click
    assert_equal "name = #{@fact_name.name}", find_field('search').value
  end

  test "value fact links" do
    visit fact_values_path
    click_link(@value.value)
    assert_equal "facts.#{@fact_name.name} = \"#{@value.value}\"", find_field('search').value
  end
end

class ChildFactValueIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @host = FactoryGirl.create(:host)
    @parent_name = FactoryGirl.create(:fact_name, :compose => true)
    @parent_value = FactoryGirl.create(:fact_value, :value => nil, :host => @host, :fact_name => @parent_name)

    @child_suffix = 'child'
    @child_name = FactoryGirl.create(:fact_name, :name => "#{@parent_name.name}::#{@child_suffix}", :short_name => @child_suffix, :ancestry => @parent_name.id)
    @child_value = FactoryGirl.create(:fact_value, :host => @host, :fact_name => @child_name)
  end

  test "parent name links to child list" do
    visit fact_values_path
    assert page.has_link? @parent_name.name

    #click on the parent name link
    within(:xpath, "//tr[contains(.,'#{@parent_name.name}')]") do
      assert_equal "Show all #{@parent_name.name} children fact values", first(:xpath, "//td[2]//li[1]//a[2]")[:title]
      first(:xpath, "//td[2]//a[1]").click
    end

    #click on the child name link
    within(:xpath, "//tr[contains(.,'#{@child_name.short_name}')]") do
      assert_equal "Show #{@child_name.name} fact values for all hosts", first(:xpath, "//td[1]//a")[:title]
      first(:xpath, "//td[1]//a").click
    end

    assert_equal "Show all #{@parent_name.name} children fact values", first(:xpath, "//td[2]//a")[:'title']
  end
end
