require 'test_helper'

class SmartProxyTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
     assert_delete_row(smart_proxies_path, "Unused Proxy")
  end

  test "cannot delete row if used" do
     assert_cannot_delete_row(smart_proxies_path, "DHCP Proxy", "Delete",true)
  end

  #PENDING - Certificates, Autosign, Import Subnets
end
