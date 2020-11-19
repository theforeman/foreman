require 'integration_test_helper'

class ParametersPermissionsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    role = FactoryBot.create(:role)
    @filter = FactoryBot.create(:filter,
      :permissions => Permission.where(:name => ['view_params']),
      :search => 'name ~ a* or domain_name ~ example*com',
      :role => role)
    domain_filter = FactoryBot.create(:filter, :permissions => Permission.where(:name => ['edit_domains', 'view_domains']))

    role.filters = [@filter, domain_filter]
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
      assert page.has_no_content?(@invisible_global_parameter.name)

      parameter_row_css = "tr#common_parameter_#{@visible_global_parameter.id}_row"
      within parameter_row_css do
        assert page.has_link?(@visible_global_parameter.name)
      end
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

  describe "domain parameters" do
    before do
      @domain1 = FactoryBot.create(:domain, :name => 'example.tst')
      @visible_domain_parameter = FactoryBot.create(:domain_parameter, :domain => @domain1, :name => 'a_parameter')
      @invisible_domain_parameter = FactoryBot.create(:domain_parameter, :domain => @domain1, :name => 'b_parameter')

      @domain2 = FactoryBot.create(:domain)
      @domain_visible_domain_parameter = FactoryBot.create(:domain_parameter, :domain => @domain2, :name => 'c_parameter')
    end

    test "user can only see domain parameters limited by filter on name or domain" do
      visit edit_domain_path(@domain1)
      refute_visible_parameter(@invisible_domain_parameter)
      refute_user_can_see_domain_parameter_remove_link(@visible_domain_parameter)
      assert_visible_parameter(@visible_domain_parameter)

      visit edit_domain_path(@domain2)
      assert_visible_parameter(@domain_visible_domain_parameter)
    end

    test "user can edit domain parameters limited by filter on name or domain" do
      @filter.permissions << Permission.find_by_name('edit_params')

      visit edit_domain_path(@domain1)
      refute_visible_parameter(@invisible_domain_parameter)
      refute_user_can_see_domain_parameter_remove_link(@visible_domain_parameter)
      assert_domain_parameter_can_be_edited(@domain1, @visible_domain_parameter)
      assert_domain_parameter_can_be_edited(@domain2, @domain_visible_domain_parameter)
    end

    test "user can destroy only domain parameters limited by filter on name or domain" do
      @filter.permissions << Permission.find_by_name('destroy_params')
      assert_domain_parameter_can_be_deleted(@domain1, @visible_domain_parameter)
      assert_domain_parameter_can_be_deleted(@domain2, @domain_visible_domain_parameter)
    end
  end

  private

  def assert_visible_parameter(parameter)
    assert page.has_css?("input[value=#{parameter.name}][type=text][disabled=disabled]")
  end

  def refute_visible_parameter(parameter)
    assert page.has_no_css?("input[value=#{parameter.name}][type=text]")
  end

  def assert_domain_parameter_can_be_edited(domain, parameter)
    visit edit_domain_path(domain)
    assert page.has_css?("input[value=#{parameter.name}][type=text]")

    fill_in "domain_parameter_#{parameter.id}_value", :with => 'new_value'
    click_button 'Submit'

    visit edit_domain_path(domain)
    parameter_area = find(:css, "#domain_parameter_#{parameter.id}_value")
    assert_equal 'new_value', parameter_area.text
  end

  def assert_domain_parameter_can_be_deleted(domain, parameter)
    visit edit_domain_path(domain)
    within("tr#domain_parameter_#{parameter.id}_row") do
      assert page.has_link?('Remove')
      # click_link 'remove' (we don't want to use JS here)
      hidden = find(:css, "#domain_domain_parameters_attributes_0__destroy", :visible => false)
      hidden.set '1'
    end
    click_button 'Submit'
    visit edit_domain_path(domain)
    refute_visible_parameter(parameter)
  end

  def refute_user_can_see_domain_parameter_remove_link(parameter)
    within("tr#domain_parameter_#{parameter.id}_row") do
      assert page.has_no_link?('remove')
    end
  end
end
