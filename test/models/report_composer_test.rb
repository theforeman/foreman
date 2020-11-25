require 'test_helper'

class ReportComposerTest < ActiveSupport::TestCase
  let(:template) { "some content" }

  def setup
    @report_template = FactoryBot.create(:report_template, :with_input, :template => template)
    @template_input = @report_template.template_inputs.first
    @composer_params = {
      :template_id => @report_template.id,
      :input_values => { @template_input.id.to_s => { 'value' => 'hello' } },
    }
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

  describe '#generate_at handling' do
    context 'API' do
      it 'translate generate_at as UTC time in API' do
        params = { id: @report_template.id, generate_at: '2019-04-15 15:10' }
        params.expects(:permit!).returns(params.with_indifferent_access)
        composer = ReportComposer.from_api_params(params)
        composer.generate_at.utc.hour == 15
      end

      it 'respect given timezone' do
        params = { id: @report_template.id, generate_at: '2019-04-15 15:10 +2' }
        params.expects(:permit!).returns(params.with_indifferent_access)
        composer = ReportComposer.from_api_params(params)
        composer.generate_at.utc.hour == 13
      end
    end
  end

  describe '#render' do
    it 'renders a simple template' do
      body = "<%= 1 + 1 %> <%= input('#{@template_input.name}') %>"
      @report_template.update_attribute :template, body
      composer = ReportComposer.new(@composer_params) # to reload the inner template instance
      assert_equal composer.render, '2 hello'
    end

    describe 'formats' do
      let(:template) do
        "<%= report_headers('one', 'two'); report_row(one: 1, two: 2); report_row(one: 1, two: 2); report_render -%>"
      end

      it 'JSON' do
        expected = "[{\"one\":1,\"two\":2},{\"one\":1,\"two\":2}]"
        assert_equal expected, @composer.render(params: {format: ReportTemplateFormat.find(:json)})
      end

      it 'YAML' do
        expected = "---\n- one: 1\n  two: 2\n- one: 1\n  two: 2\n"
        assert_equal expected, @composer.render(params: {format: ReportTemplateFormat.find(:yaml)})
      end

      it 'CSV' do
        expected = "one,two\n1,2\n1,2\n"
        assert_equal expected, @composer.render(params: {format: ReportTemplateFormat.find(:csv)})
      end

      it 'HTML' do
        expected = %r{<table><thead><tr><th>one</th><th>two</th></tr></thead><tbody><tr><td>1</td><td>2</td></tr><tr><td>1</td><td>2</td></tr></tbody></table>}
        assert_match expected, @composer.render(params: {format: ReportTemplateFormat.find(:html)})
      end

      it 'TXT' do
        expected = "one,two\n1,2\n1,2\n"
        assert_equal expected, @composer.render(params: {format: ReportTemplateFormat.find(:txt)})
      end
    end
  end
end
