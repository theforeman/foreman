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

  class ParamParser
    attr_reader :raw_params

    def mail_to
      raw_params[:mail_to]
    end

    def gzip?
      raw_params[:gzip].nil? ? send_mail? : !!raw_params[:gzip]
    end

    def send_mail?
      raw_params['send_mail'].to_s == '1'
    end

    def generate_at
      raw_params['generate_at']&.to_time
    end

    def format
      raw_params['format']
    end

    def params
      { template_id: raw_params[:id],
        generate_at: generate_at,
        gzip: gzip?,
        send_mail: send_mail?,
        mail_to: mail_to,
        format: format }.with_indifferent_access
    end
  end

  class UiParams < ParamParser
    def initialize(raw_params)
      @raw_params = raw_params.permit!
    end

    def send_mail?
      report_base_params['send_mail'].to_s == '1'
    end

    def mail_to
      report_base_params[:mail_to]
    end

    def generate_at
      Time.zone.parse(report_base_params['generate_at']) if report_base_params['generate_at'].present?
    end

    def format
      report_base_params['format']
    end

    def params
      super.merge(input_values: report_base_params[:input_values])
    end

    def report_base_params
      (raw_params[:report_template_report] || {}).to_hash.with_indifferent_access
    end
  end

  class ApiParams < ParamParser
    def initialize(raw_params)
      @raw_params = raw_params.permit!
    end

    def send_mail?
      !!mail_to
    end

    def generate_at
      Time.find_zone("UTC").parse(raw_params['generate_at']) if raw_params['generate_at'].present?
    end

    def params
      super.merge(
        input_values: convert_input_names_to_ids(
          raw_params[:id],
          (raw_params[:input_values] || {}).to_hash
        ),
        format: raw_params[:report_format]
      )
    end

    def convert_input_names_to_ids(template_id, input_values)
      inputs = TemplateInput.where(:template_id => template_id, :name => input_values.keys)
      Hash[inputs.map { |i| [i.id.to_s, 'value' => input_values[i.name]] }]
    end
  end

  class MailToValidator < ActiveModel::EachValidator
    MAIL_DELIMITER = ','

    def validate_each(model, attribute, value)
      return if value.empty?
      value.split(MAIL_DELIMITER).each do |mail|
        mail_validator.validate_each(model, attribute, mail.strip)
      end
    end

    def mail_validator
      @mail_validator ||= EmailValidator.new(attributes: attributes)
    end
  end

  attr_reader :template, :generate_at

  validates :mail_to, mail_to: true, if: :send_mail?
  validate :valid_format

  def initialize(params)
    @params = params.with_indifferent_access
    @generate_at = @params.delete('generate_at')
    @template = load_report_template(@params[:template_id])
    @input_values = build_inputs(@template, @params[:input_values])
  end

  def self.from_ui_params(ui_params)
    new(UiParams.new(ui_params).params)
  end

  def self.from_api_params(api_params)
    new(ApiParams.new(api_params).params)
  end

  def build_inputs(template, input_values)
    inputs = {}.with_indifferent_access
    return inputs if template.nil?

    # process values from params (including empty hash)
    template.template_inputs.each do |input|
      val = input_values[input.id.to_s].try(:[], 'value') unless input_values.nil?
      val = input.default if val.blank?
      inputs[input.id.to_s] = InputValue.new(value: val, template_input: input)
    end

    inputs
  end

  def to_param
    @params.to_param
  end

  def to_params
    @params
  end

  def valid?
    res = super & @input_values.map { |_, input_value| input_value.valid? }.all?
    merge_input_errors unless res
    res
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
    !!@params['gzip']
  end

  def mime_type
    gzip? ? :gzip : format.mime_type
  end

  def format
    if (format = ReportTemplateFormat.find(@params['format']))
      format
    else
      Rails.logger.debug "Report format #{@params['format']} not found" if @params['format'].present?
      @template.supports_format_selection? ? ReportTemplateFormat.default : ReportTemplateFormat.system
    end
  end

  def valid_format
    return true if @params['format'].blank?
    format_ids = ReportTemplateFormat.all.map { |f| f.id.to_s }
    errors.add :format, "is unsupported, chose one of: %s" % format_ids.join(', ') unless format_ids.include?(@params['format'])
  end

  def send_mail?
    !!@params['send_mail']
  end
  alias_method :send_mail, :send_mail?

  def mail_to
    @params['mail_to'] || User.current.mail
  end

  def report_filename
    name = @template.suggested_report_name.to_s
    name += '.' + format.extension
    name += '.gz' if gzip?
    name
  end

  def schedule_rendering
    scheduler = TemplateRenderJob
    if generate_at
      scheduler = scheduler.set(wait_until: generate_at)
    end
    scheduler.perform_later(to_params, user_id: User.current.id)
  end

  def render(mode: Foreman::Renderer::REAL_MODE, **params)
    params[:params] = { :format => format }.merge(params.fetch(:params, {}))
    result = @template.render(mode: mode, template_input_values: template_input_values, **params)
    result = ActiveSupport::Gzip.compress(result) if gzip?
    result
  end

  private

  def merge_input_errors
    @input_values.each do |id, input_value|
      input_value.errors.full_messages.each do |message|
        errors.add :base, (_("Input %s: ") % input_value.template_input.name) + message
      end
    end
  end
end
