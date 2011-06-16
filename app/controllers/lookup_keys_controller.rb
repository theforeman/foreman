class LookupKeysController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :find_by_key, :except => :index
  before_filter :setup_search_options, :only => :index

  def index
    begin
      values = LookupKey.search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = LookupKey.search_for ""
    end

    respond_to do |format|
      format.html do
        @lookup_keys = values.paginate(:page => params[:page], :include => [:lookup_values, :puppetclass])
      end
      format.json { render :json => values}
    end
  end

  def edit
  end

  def update
    if @lookup_key.update_attributes(params[:lookup_key])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @lookup_key.destroy
      process_success
    else
      process_error
    end
  end

  private
  def find_by_key
    if params[:id]
      not_found and return unless @lookup_key = LookupKey.find_by_key(params[:id])
    end
  end
end
