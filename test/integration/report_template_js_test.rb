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

    template_text = "CPUs,RAM,HDD\n<%= input(\'cpus\') -%>,<%= 1024 -%> MB,N/A"

    fill_in :id => 'report_template_name', :with => 'A testing report'
    fill_in_editor_field('#editor-container', template_text)
    assert has_editor_display?('#editor-container', template_text)

    click_link('Inputs')
    within "#template_inputs" do
      assert page.has_no_content?('Input Type')

      click_link '+ Add Input'
      assert page.has_content?('Input Type')

      # set the input name, there's no good identifier for nested fields
      first('input.form-control').set('cpus')
    end

    find('input[name="commit"]').click

    template = ReportTemplate.find_by_name('A testing report')
    visit generate_report_template_path(template)

    assert_equal template.template, template_text

    assert page.has_content?('cpus')
  end

  test "advanced link show/hides advanced inputs" do
    template = FactoryBot.create(:report_template, :with_input)
    input = template.template_inputs.first
    input.update :advanced => true

    visit generate_report_template_path(template)
    within '#content' do
      assert page.has_no_content? input.name

      click_link 'Display advanced fields'
      assert page.has_content? input.name

      click_link 'Hide advanced fields'
      assert page.has_no_content? input.name
    end
  end

  test "ouput options for templates with report_render method" do
    template = FactoryBot.create(:report_template, :with_report_render)
    output_options = ['CSV', 'JSON', 'YAML', 'HTML']

    visit generate_report_template_path(template)
    find('#s2id_report_template_report_format').click

    output_options.each { |opt| assert page.has_content? opt }
  end

  test "ouput options for templates without report_render method" do
    template = FactoryBot.create(:report_template)

    visit generate_report_template_path(template)
    select = find('#s2id_report_template_report_format')

    assert select.text ''
    assert select[:class].include?('select2-container-disabled'), true
  end

  test "should have correct generate_at field" do
    template = FactoryBot.create(:report_template)
    visit generate_report_template_path(template)

    assert_equal 'report_template_report[generate_at]', find('#report_template_report_generate_at')['name']
  end
end
