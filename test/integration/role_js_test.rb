require 'integration_test_helper'
require_relative '../test_helper'

class RoleJSTest < IntegrationTestWithJavascript
  test "index page" do
    assert_index_page(roles_path, "Roles", "Create Role")
  end

  # BZ: 1277444
  # Expected results: more than one page of filters can be displayed on the role filters page
  test "filters page supports pagination" do
    with_temporary_settings(entries_per_page: 1) do
      role = FactoryBot.create(:role)
      permissions = FactoryBot.create_list(:permission, 2, :host)
      permissions.each do |permission|
        FactoryBot.create(:filter, role: role, permissions: [permission], search: nil)
      end

      visit filters_path(role_id: role.id)
      assert_breadcrumb_text("#{role.name} filters")

      assert_selector('.tfm-pagination[data-total="2"][data-per-page="1"]')
      assert_equal 1, all('table tbody tr').size

      find('button[data-action="next"]').click
      assert_equal 1, all('table tbody tr').size
    end
  end
end
