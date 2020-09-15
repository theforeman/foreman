require 'test_helper'

class TemplateInputTest < ActiveSupport::TestCase
  let(:template_input) { FactoryBot.build(:template_input) }

  context 'export' do
    before do
      template_input.input_type = 'user'
      template_input.options = "foo\nbar\nbaz"
    end

    it 'exports type' do
      _(template_input.to_export['input_type']).must_equal template_input.input_type
    end

    it 'exports options' do
      _(template_input.to_export['options']).must_equal template_input.options
    end
  end

  context 'user input' do
    before { template_input.input_type = 'user' }
    it { assert template_input.user_template_input? }
  end

  context 'fact input' do
    before { template_input.input_type = 'fact' }
    it { assert template_input.fact_template_input? }
  end

  context 'variable input' do
    before { template_input.input_type = 'variable' }
    it { assert template_input.variable_template_input? }
  end

  context 'puppet parameter input' do
    before { template_input.input_type = 'puppet_parameter' }
    it { assert template_input.puppet_parameter_template_input? }
  end

  test "Input should not be created for locked template" do
    report_template = FactoryBot.create(:report_template, :locked)
    template_input = TemplateInput.new(:name => "Ubuntu", :input_type => "user", :template => report_template)

    refute template_input.valid?, "This template is locked. Please clone it to a new template to customize."
    assert_includes template_input.errors.keys, :base
  end

  test "Input should be created for unlocked template" do
    report_template = FactoryBot.create(:report_template, :with_input)
    template_input_count = report_template.template_inputs.count

    template_input = TemplateInput.new(:name => "Ubuntu", :input_type => "user", :template_id => report_template.id)
    assert template_input.save!

    assert_equal template_input_count + 1, report_template.template_inputs.count
  end

  test "Input should not be updated for locked template" do
    report_template = FactoryBot.create(:report_template, :with_input, :locked)
    template_input = report_template.template_inputs.first
    template_input.reload

    old_name = template_input.name
    template_input.update(:name => "#{old_name}_renamed")

    refute template_input.valid?, "This template is locked. Please clone it to a new template to customize."
    assert_includes template_input.errors.keys, :base
  end

  test "Input should not be destroyed for locked template" do
    report_template = FactoryBot.create(:report_template, :with_input, :locked)
    template_input_count = report_template.template_inputs.count
    template_input = report_template.template_inputs.first

    assert !template_input.destroy
    assert_equal template_input_count, report_template.template_inputs.count
  end

  test "Input should be destroyed for unlocked template" do
    report_template = FactoryBot.create(:report_template, :with_input, :locked => false)
    template_input_count = report_template.template_inputs.count
    template_input = report_template.template_inputs.first

    assert template_input.destroy
    assert_equal template_input_count - 1, report_template.template_inputs.count
  end
end
