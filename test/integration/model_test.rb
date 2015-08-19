require 'test_helper'

class ModelIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(models_path,"Hardware Models","New Model")
  end

  test "create new page" do
    assert_new_button(models_path,"New Model",new_model_path)
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
end
