require 'integration_test_helper'

class ReportTemplateJSIntegrationTest < IntegrationTestWithJavascript
  test "index page" do
    as_admin do
      FactoryBot.create(:report_template) # breadcrumbs are not present on welcome page
      assert_index_page(report_templates_path, "Report Templates", "Create Template")
    end
  end

  test "creating report templates with inputs, displaying them when generating the template" do
    visit report_templates_path
    assert page.has_link?('Create Report Template')

    click_link 'Create Report Template'
    fill_in :id => 'report_template_name', :with => 'A testing report'
    find('#editor').click
    find('.ace_content').send_keys "CPUs,RAM,HDD\n<%= input('cpus') -%>,<%= 1024 -%> MB,N/A"
    sleep 1 # Wait for the editor onChange debounce

    click_link('Inputs')
    within "#template_inputs" do
      refute page.has_content?('Input Type')

      click_link '+ Add Input'
      assert page.has_content?('Input Type')

      # set the input name, there's no good identifier for nested fields
      first('input.form-control').set('cpus')
    end

    find('input[name="commit"]').click

    template = ReportTemplate.find_by_name('A testing report')
    visit generate_report_template_path(template)

    assert page.has_content?('cpus')
  end

  test "advanced link show/hides advanced inputs" do
    template = FactoryBot.create(:report_template, :with_input)
    input = template.template_inputs.first
    input.update :advanced => true

    visit generate_report_template_path(template)
    within '#content' do
      refute page.has_content? input.name

      click_link 'Display advanced fields'
      assert page.has_content? input.name

      click_link 'Hide advanced fields'
      refute page.has_content? input.name
    end
  end
end
