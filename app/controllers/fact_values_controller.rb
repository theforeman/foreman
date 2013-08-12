class FactValuesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :setup_search_options, :only => :index

  def index
    begin
      values = FactValue.my_facts.no_timestamp_facts.search_for(params[:search],:order => params[:order])
    rescue => e
      error e.to_s
      values = FactValue.no_timestamp_facts.search_for ""
    end

    respond_to do |format|
      format.html do
        @fact_values = values.required_fields.paginate :page => params[:page]
      end
      format.json do
        render :json => FactValue.build_facts_hash(values.all(:include => [:fact_name, :host]))
      end
    end
  end

end
