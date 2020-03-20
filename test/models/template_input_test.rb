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
end
