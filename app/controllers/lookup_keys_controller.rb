# Base class for all LookupKeys descendants controllers
# The index method needs to be always implemented in the subclass
class LookupKeysController < ApplicationController
  MAX_LOOKUP_VALUES_JSON_BYTES = 2.megabytes

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
  rescue JSON::ParserError => e
    logger.error e.message
    process_error(error_msg: e.message)
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

    unless json.is_a?(String) && json.bytesize <= MAX_LOOKUP_VALUES_JSON_BYTES
      raise JSON::ParserError, _("Override values payload is not valid or exceeds the maximum size.")
    end
    return if json.blank?
    values = begin
      JSON.parse(json)
    rescue JSON::ParserError
      raise JSON::ParserError, _("Override values are not valid JSON.")
    end
    unless values.is_a?(Array) && values.all? { |value| value.is_a?(Hash) }
      raise JSON::ParserError, _("Override values must be a list of override rows.")
    end

    values.each_with_index.to_h do |value, index|
      permitted = ActionController::Parameters.new(value).permit(:match, :value, :omit, :id, :_destroy)
      attrs = permitted.to_h
      destruction = attrs['id'].present? && ActiveModel::Type::Boolean.new.cast(attrs['_destroy'])
      destruction_only = destruction && !value.key?('match') && attrs.except('id', '_destroy').empty?
      unless destruction_only || (attrs['match'].is_a?(String) && attrs['match'].present?)
        raise JSON::ParserError, _("Each override must have a matcher.")
      end
      attrs['_destroy'] = '1' if destruction
      [index.to_s, attrs]
    end
  end

  def sanitize_attrs(attrs)
    to_delete, rest = attrs.partition { |_k, v| v["_destroy"] == "1" }.map { |arr| Hash[arr] }
    matches = rest.each_with_object({}) do |(key, value), index|
      queue = (index[value['match']] ||= { rows: [], offset: 0 })
      queue[:rows] << [key, value]
    end
    to_delete.each do |key, value|
      queue = matches[value['match']]
      f_key, f_value = queue && queue[:rows][queue[:offset]]
      unless f_key.nil?
        queue[:offset] += 1
        rest.delete(f_key)
        replacement = value.merge(f_value)
        rest[key] = replacement
        queue[:rows] << [key, replacement]
      end
    end
    to_delete.merge(rest)
  end

  def controller_permission
    'external_variables'
  end
end
