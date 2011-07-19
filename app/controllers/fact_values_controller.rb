class FactValuesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  skip_before_filter :require_ssl,               :only => :create
  skip_before_filter :require_login,             :only => :create
  skip_before_filter :authorize,                 :only => :create
  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :set_admin_user, :only => :create
  before_filter :setup_search_options, :only => :index

  # avoids storing the facts data in the log files
  filter_parameter_logging :facts

  def index
    begin
      values = FactValue.no_timestamp_facts.search_for(params[:search],:order => params[:order])
      flash.clear
    rescue => e
      error e.to_s
      values = FactValue.no_timestamp_facts.search_for ""
    end

    respond_to do |format|
      format.html do
        @fact_values = values.paginate :page => params[:page]
        @timestamps  = FactValue.timestamp_facts.host_id_eq(@fact_values.map(&:host_id).uniq)
      end
      format.json do
        render :json => FactValue.build_facts_hash(values.all(:include => [:fact_name, :host]))
      end
    end
  end

  def create
    respond_to do |format|
      format.yml {
        if Host.importHostAndFacts params.delete("facts")
          render :text => "Imported facts", :status => 200 and return
        else
          render :text => "Failed to import facts", :status => 400
        end
      }
    end
  end

end
