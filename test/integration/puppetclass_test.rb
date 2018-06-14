require 'integration_test_helper'

class PuppetclassIntegrationTest < IntegrationTestWithJavascript
  # intermittent failures:
  #   PuppetclassIntegrationTest.test_0001_edit page

  test "edit page" do
    visit puppetclasses_path
    click_link "vim"
    assert page.has_no_link? 'Common'
    find(:xpath, "//a[@data-original-title='Select All']").click
    assert_submit_button(puppetclasses_path)
    assert page.has_link? 'vim'
    assert page.has_link? 'Common'
  end

  test 'verify key label exists in case key is too long' do
    env_long = FactoryBot.create(:environment)
    puppet_class_long = FactoryBot.create(:puppetclass, :environments => [env_long])
    smart_class_parameter_long = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :puppetclass => puppet_class_long, :variable => "a" * 50)
    smart_variable_long = FactoryBot.create(:variable_lookup_key, :key_type => '', :puppetclass => puppet_class_long, :key => "c" * 50)
    visit edit_puppetclass_path(puppet_class_long)
    click_link 'Smart Class Parameter'
    assert_equal smart_class_parameter_long.key, page.find("#pill_#{smart_class_parameter_long.id}-#{smart_class_parameter_long.key}")['data-original-title']
    click_link 'Smart Variables'
    assert_equal smart_variable_long.key, page.find("#pill_#{smart_variable_long.id}-#{smart_variable_long.key}")['data-original-title']
  end

  test 'verify key label is empty in case key is short' do
    env_short = FactoryBot.create(:environment)
    puppet_class_short = FactoryBot.create(:puppetclass, :environments => [env_short])
    smart_class_parameter_short = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :puppetclass => puppet_class_short, :variable => "a" * 40)
    smart_variable_short = FactoryBot.create(:variable_lookup_key, :key_type => '', :puppetclass => puppet_class_short, :key => "c" * 40)
    visit edit_puppetclass_path(puppet_class_short)
    click_link 'Smart Class Parameter'
    assert_empty page.find("#pill_#{smart_class_parameter_short.id}-#{smart_class_parameter_short.key}")['data-original-title']
    click_link 'Smart Variables'
    assert_empty page.find("#pill_#{smart_variable_short.id}-#{smart_variable_short.key}")['data-original-title']
  end

  # PENDING
  # test "smart variables" do
  # end

  # PENDING
  # test "smart class parameters" do
  # end
end
