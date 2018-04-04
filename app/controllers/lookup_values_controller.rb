class LookupValuesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::LookupValue

  before_action :find_resource, :only => [:update, :destroy]
  before_action :setup_search_options, :only => :index

  def index
    begin
      values = LookupValue.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      Foreman::Logging.exception("Failed loading lookup values", e)
      values = LookupValue.search_for ""
    end
    @lookup_values = values.paginate(:page => params[:page])
  end

  def create
    @lookup_value = LookupValue.new(lookup_value_params)
    if @lookup_value.save
      process_success({:success_redirect => lookup_key_lookup_values_url(params[:lookup_key_id])})
    else
      process_error
    end
  end

  def update
    if @lookup_value.update(lookup_value_params)
      process_success({:success_redirect => lookup_key_lookup_values_url(params[:lookup_key_id])})
    else
      process_error
    end
  end

  def destroy
    if @lookup_value.destroy
      process_success({:success_redirect => lookup_key_lookup_values_url(params[:lookup_key_id])})
    else
      process_error
    end
  end
end
