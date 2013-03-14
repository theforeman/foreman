require 'test_helper'

class SettingTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(settings_path,"Settings",false,true,false)
  end

end
