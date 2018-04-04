class LookupKeysController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_action :setup_search_options, :only => :index
  before_action :find_resource, :only => [:edit, :update, :destroy], :if => Proc.new { params[:id] }

  def index
    @lookup_keys = resource_base_search_and_page(:puppetclass)
    @puppetclass_authorizer = Authorizer.new(User.current, :collection => @lookup_keys.map(&:puppetclass_id).compact.uniq)
  end

  def edit
  end

  def update
    if resource.update(resource_params.merge(:lookup_values_attributes => sanitize_attrs))
      process_success
    else
      process_error
    end
  end

  def destroy
    if resource.destroy
      process_success
    else
      process_error
    end
  end

  private

  def sanitize_attrs
    attrs = resource_params.fetch(:lookup_values_attributes, {})
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
