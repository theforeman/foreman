require 'test_helper'

class ReportComposerTest < ActiveSupport::TestCase
  def setup
    @report_template = FactoryBot.create(:report_template, :with_input)
    @template_input = @report_template.template_inputs.first
    @composer_params = {:template_id => @report_template.id, :input_values => { @template_input.id.to_s => { 'value' => 'hello' } }}
    @composer = ReportComposer.new(@composer_params)
  end

  test 'template_input_values returns hash of inputs and their values' do
    assert @composer.template_input_values.key?(@template_input.name)
    assert_equal 'hello', @composer.template_input_values[@template_input.name]
  end

  test 'input_value_for(input) find value by input id' do
    assert_not_nil @composer.input_value_for(@template_input)
  end

  test 'load_report_template(id) loads the template by id' do
    assert_equal @report_template, @composer.load_report_template(@report_template.id)
  end

  test 'valid checks input values validity' do
    @template_input.toggle! :required
    assert @composer.valid?

    invalid = ReportComposer.new(:template_id => @report_template.id, :input_values => { })
    refute invalid.valid?

    assert_includes invalid.errors.full_messages, "Input #{@template_input.name}: Value can't be blank"
  end

  test 'can be created from UI params' do
    params = { :id => @report_template.id, :report_template_report => { :input_values => { @template_input.id.to_s => { 'value' => 'hello' } } } }
    params.expects(:permit!).returns(params)
    composer = ReportComposer.from_ui_params(params)
    assert_equal 'hello', composer.template_input_values[@template_input.name]
  end

  test 'can be created from API params' do
    params = { :id => @report_template.id, :input_values => { @template_input.name => 'hello' } }
    params.expects(:permit!).returns(params)
    composer = ReportComposer.from_api_params(params)
    assert_equal 'hello', composer.template_input_values[@template_input.name]
  end

  describe '#render_to_store' do
    it 'writes rendered template to the store' do
      @report_template.update_attribute :template, "<%= 1 + 1 %> <%= input('#{@template_input.name}') %>"
      StoredValue.expects('write').with('STORE-UNIQUE-KEY', '2 hello', has_key(:expire_at)).returns(true)
      composer = ReportComposer.new(@composer_params) # to reload the inner template instance
      composer.render_to_store('STORE-UNIQUE-KEY')
    end

    it 'passes params to the render method' do
      StoredValue.expects('write').with('STORE-UNIQUE-KEY', 'val', has_key(:expire_at)).returns(true)
      ReportTemplate.any_instance
        .expects('render')
        .with(mode: Foreman::Renderer::REAL_MODE, template_input_values: @composer.template_input_values, foo: 'bar')
        .returns('val')
      @composer.render_to_store('STORE-UNIQUE-KEY', foo: 'bar')
    end
  end
end
