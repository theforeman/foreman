# Base class for all LookupKeys descendants controllers
# The index method needs to be always implemented in the subclass
class LookupKeysController < ApplicationController
  # Bound JSON parsing and the quadratic sibling uniqueness validation. These
  # limits allow substantially more than the required 4,097 matcher rows.
  MAX_LOOKUP_VALUES_JSON_BYTES = 2.megabytes
  MAX_LOOKUP_VALUES_JSON_ROWS = 8192

  include Foreman::Controller::AutoCompleteSearch
  before_action :setup_search_options, :only => :index
  before_action :find_resource, :only => [:edit, :update, :destroy], :if => proc { params[:id] }

  def edit
  end

  def update
    attrs = resource_params.except(:lookup_values_json)
    lookup_values = lookup_values_json_attributes || attrs.fetch(:lookup_values_attributes, {})
    if resource.update(attrs.merge(lookup_values_attributes: sanitize_attrs(lookup_values)))
      process_success
    else
      process_error
    end
  rescue JSON::ParserError
    process_error(error_msg: _("Invalid lookup values JSON: expected valid override rows within the supported limits"))
  end

  def destroy
    if resource.destroy
      process_success
    else
      process_error
    end
  end

  protected

  def resource
    instance_variable_get("@#{resource_name}")
  end

  def resource_params
    send("#{resource_name}_params")
  end

  private

  def lookup_values_json_attributes
    json = resource_params[:lookup_values_json]
    return if json.nil?

    raise JSON::ParserError unless json.is_a?(String) && json.bytesize <= MAX_LOOKUP_VALUES_JSON_BYTES
    return if json.blank?
    values = JSON.parse(json)
    unless values.is_a?(Array) && values.size <= MAX_LOOKUP_VALUES_JSON_ROWS && values.all? { |value| value.is_a?(Hash) }
      raise JSON::ParserError
    end

    values.each_with_index.to_h do |value, index|
      permitted = ActionController::Parameters.new(value).permit(:match, :value, :omit, :id, :_destroy)
      attrs = permitted.to_h
      destruction = attrs['id'].present? && ActiveModel::Type::Boolean.new.cast(attrs['_destroy'])
      destruction_only = destruction && !value.key?('match') && attrs.except('id', '_destroy').empty?
      unless destruction_only || (attrs['match'].is_a?(String) && attrs['match'].present?)
        raise JSON::ParserError
      end
      attrs['_destroy'] = '1' if destruction
      [index.to_s, attrs]
    end
  end

  def sanitize_attrs(attrs)
    to_delete, rest = attrs.partition { |_k, v| v["_destroy"] == "1" }.map { |arr| Hash[arr] }
    to_delete.each do |key, value|
      f_key, _value = rest.find { |_, f_value| f_value['match'] == value['match'] }
      unless f_key.nil?
        f_value = rest.delete f_key
        rest.update(key => value.merge(f_value))
      end
    end
    to_delete.merge(rest)
  end

  def controller_permission
    'external_variables'
  end
end
