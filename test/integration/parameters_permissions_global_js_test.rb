require 'integration_test_helper'

class ParametersPermissionsGlobalJSTest < IntegrationTestWithJavascript
  setup do
    role = FactoryBot.create(:role)
    @filter = FactoryBot.create(:filter,
                                 :permissions => Permission.where(:name => ['view_params']),
                                 :search => 'name ~ a* or domain_name ~ example*com',
                                 :role => role)
    domain_filter = FactoryBot.create(:filter, :permissions => Permission.where(:name => ['edit_domains', 'view_domains']))

    role.filters = [ @filter, domain_filter ]
    @user = FactoryBot.create(:user, :with_mail)
    @user.roles << role

    set_request_user(@user)
  end

  describe "global parameters" do
    before do
      @visible_global_parameter = FactoryBot.create(:common_parameter, :name => "a_parameter")
      @invisible_global_parameter = FactoryBot.create(:common_parameter, :name => "b_parameter")
    end

    test "user can only see global parameters limited by filter on name" do
      visit common_parameters_path
      assert page.has_no_text?('Delete')
      assert page.has_content?(@visible_global_parameter.name)
      assert page.has_no_content?(@invisible_global_parameter.name)
    end

    test "user can edit global parameters limited by filter on name" do
      @filter.permissions << Permission.find_by_name('edit_params')
      visit common_parameters_path
      assert page.has_no_text?('Delete')
      assert page.has_content?(@visible_global_parameter.name)
      assert page.has_no_content?(@invisible_global_parameter.name)
      click_link @visible_global_parameter.name
      find('#editor').click
      find('.ace_content').send_keys "another_value"
      sleep 1 # Wait for the editor onChange debounce
      click_button 'Submit'
      assert page.has_text? 'another_value'
    end

    test "user can delete global parameters limited by filter on name" do
      @filter.permissions << Permission.find_by_name('destroy_params')
      visit common_parameters_path
      assert page.has_content?(@visible_global_parameter.name)
      assert page.has_no_content?(@invisible_global_parameter.name)

      parameter_row_css = "tr#common_parameter_#{@visible_global_parameter.id}_row"
      within parameter_row_css do
        click_link 'Delete'
      end

      assert page.has_no_css? "tr#common_parameter_#{@visible_global_parameter.id}_row"
    end
  end
end
