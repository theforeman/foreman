require 'integration_test_helper'

class MediaJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(media_path, "Media", "Create Medium")
  end
end
