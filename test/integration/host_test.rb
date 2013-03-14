require 'test_helper'

class HostTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(hosts_path,"Hosts","New Host")
  end

end
