require 'test_helper'

class DashboardTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "Puppet Clients Activity Overview link" do
    assert page.has_link? 'Puppet Clients Activity Overview'
    #PENDING - assert that right chart pops up"
  end


end
