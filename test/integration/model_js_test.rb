require 'integration_test_helper'

class ModelIntegrationTest < IntegrationTestWithJavascript
  test "create new page" do
    visit models_path
    click_on "Create new", class: 'pf-v5-c-button'
    assert_current_path new_models_path
    fill_in "model_name", :with => "IBM 123"
    fill_in "model_hardware_model", :with => "IBMabcde"
    fill_in "model_vendor_class", :with => "ABCDE"
    fill_in "model_info", :with => "description text"
    assert_submit_button(models_path)
    assert page.has_link? "IBM 123"
  end

  test "edit page" do
    visit models_path
    click_link "KVM"
    fill_in "model_name", :with => "RHEV 123"
    assert_submit_button(models_path)
    assert page.has_link? 'RHEV 123'
  end

  test "delete model from index" do
    model = FactoryBot.create(:model, :name => "ModelDelJsIntegration")
    visit models_path
    wait_for_ajax
    row = page.find('tr', :text => model.name)
    within row do
      find('button[aria-label="Kebab toggle"]').click
    end
    find('button.pf-v5-c-menu__item', :text => 'Delete').click
    within(:css, '[data-ouia-component-id="delete-modal"]') do
      find('[data-ouia-component-id="confirm-delete"]').click
    end
    wait_for_ajax
    refute Model.exists?(model.id)
    model_row_xpath = "//tr[contains(.,'#{model.name}')]"
    assert page.find('table > tbody').has_no_xpath?(model_row_xpath)
  end
end
