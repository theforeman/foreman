require 'integration_test_helper'

class SubnetIntegrationTest < ActionDispatch::IntegrationTest
  test "edit page" do
    visit subnets_path
    click_link "one"
    assert page.has_link?('Parameters', :href => '#params')
    fill_in "subnet_name", :with => "one-secure"
    fill_in "subnet_network", :with => "10.1.1.177"
    assert_submit_button(subnets_path)
    assert page.has_link? 'one-secure'
  end

  test 'edit shows errors on invalid name for parameters values' do
    subnet = FactoryBot.create(:subnet_ipv4)
    subnet.subnet_parameters.create!(:name => "foo_param", :value => "bar", :hidden_value => true)
    visit edit_subnet_path(subnet)
    assert page.has_link?('Parameters', :href => '#params')
    click_link 'Parameters'
    assert page.has_no_selector?('#params .input-group.has-error')
    fill_in "subnet_subnet_parameters_attributes_0_name", :with => 'invalid name'
    click_button('Submit')
    assert page.has_selector?('#params tr.has-error')
  end
end
