require 'test_helper'

class TrendTest < ActionDispatch::IntegrationTest

  setup do
    Capybara.current_driver = Capybara.javascript_driver
  end

  test "sucessfully delete row" do
    assert_delete_row(trends_path, "Operatingsystem", "Delete", true)
  end

  #PENDING - edit trend
  #selecting "Facts Trendable Type from list"

end
