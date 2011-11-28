class LookupValuesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :reject_non_json_requests
  before_filter :find_by_id, :except => [:index, :create]
  before_filter :setup_search_options, :only => :index

  def index
    begin
      values = LookupValue.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = LookupValue.search_for ""
    end

    respond_to do |format|
      format.html do
        @lookup_values = values.paginate(:page => params[:page])
      end
      format.json { render :json => values}
    end
  end

  def create
    @lookup_value = LookupValue.new(params[:lookup_value])
    if @lookup_value.save
      process_success({:success_redirect => lookup_key_lookup_values_url(params[:lookup_key_id])})
    else
      process_error
    end
  end

  def update
    if @lookup_value.update_attributes(params[:lookup_value])
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

  private

  def reject_non_json_requests
    render_403 unless api_request?
  end

  def find_by_id
    @lookup_value = LookupValue.find(params[:id])
  end

end
