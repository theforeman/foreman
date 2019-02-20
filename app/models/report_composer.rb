class ReportComposer
  include ActiveModel::Model

  class InputValue
    include ActiveModel::Model

    attr_accessor :value, :template_input

    validates :value, :presence => true, :if => proc { |v| v.template_input.required? || v.value.present? }

    validates :value, :inclusion => { :in => proc { |v| options_for_template_input v.template_input } },
              :if => proc { |v| v.template_input.input_type == 'user' && v.template_input.options_array.present? }

    class << self
      private

      def options_for_template_input(template_input)
        options = template_input.options_array
        options += [''] unless template_input.required?
        options
      end
    end
  end

  class UiParams
    attr_reader :ui_params

    def initialize(ui_params)
      @ui_params = ui_params.permit!
    end

    def params
      { template_id: ui_params[:id],
        input_values: report_base_params[:input_values],
        gzip: !!ui_params[:gzip] }.with_indifferent_access
    end

    def report_base_params
      (ui_params[:report_template_report] || {}).to_hash.with_indifferent_access
    end
  end

  class ApiParams
    attr_reader :api_params

    def initialize(api_params)
      @api_params = api_params.permit!
    end

    def params
      { template_id:  api_params[:id],
        input_values: convert_input_names_to_ids(
          api_params[:id],
          (api_params[:input_values] || {}).to_hash
        ),
        gzip: !!api_params[:gzip]}.with_indifferent_access
    end

    def convert_input_names_to_ids(template_id, input_values)
      inputs = TemplateInput.where(:template_id => template_id, :name => input_values.keys)
      Hash[inputs.map { |i| [ i.id.to_s, 'value' => input_values[i.name] ] }]
    end
  end

  def initialize(params)
    @params = params.with_indifferent_access
    @template = load_report_template(@params[:template_id])
    @input_values = build_inputs(@template, @params[:input_values])
  end

  def self.from_ui_params(ui_params)
    self.new(UiParams.new(ui_params).params)
  end

  def self.from_api_params(api_params)
    self.new(ApiParams.new(api_params).params)
  end

  def build_inputs(template, input_values)
    inputs = {}.with_indifferent_access
    return inputs if template.nil?

    # process values from params (including empty hash)
    unless input_values.nil?
      @template.template_inputs.each do |input|
        inputs[input.id.to_s] = InputValue.new(value: input_values[input.id.to_s].try(:[], 'value'), template_input: input)
      end
    end

    inputs
  end

  def to_param
    @params
  end

  def valid?
    super & @input_values.map { |_, input_value| input_value.valid? }.all?
  end

  def errors
    errors = super.dup

    @input_values.each do |id, input_value|
      input_value.errors.full_messages.each do |message|
        errors.add :base, (_("Input %s: ") % input_value.template_input.name) + message
      end
    end

    errors
  end

  def template_input_values
    Hash[@input_values.map { |_, input_value| [input_value.template_input.name, input_value.value] }]
  end

  def input_value_for(input)
    @input_values[input.id.to_s]
  end

  def load_report_template(id)
    ReportTemplate.authorized(:generate_report_templates).find_by_id(id)
  end

  def gzip?
    !!@params[:gzip]
  end

  def mime_type
    gzip? ? :gzip : :text
  end

  def report_filename
    name = @template.suggested_report_name.to_s
    name += '.gz' if gzip?
    name
  end

  def render(mode: Foreman::Renderer::REAL_MODE, **params)
    @template.render(mode: mode, template_input_values: template_input_values, **params)
  end

  def render_to_store(result_key, mode: Foreman::Renderer::REAL_MODE, **params)
    result = render(mode: mode, **params)
    result = ActiveSupport::Gzip.compress(result) if gzip?
    StoredValue.write(result_key, result, expire_at: Time.now + 1.day)
  end

  def stored_result(result_key)
    StoredValue.read(result_key)
  end
end
