require 'integration_test_helper'

class UsergroupIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    as_admin { @usergroup = FactoryBot.create(:usergroup) }
  end

  test "index page" do
    assert_index_page(usergroups_path, "User Groups", "Create User Group", false)
  end
end
