class FactValuesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :setup_search_options, :only => :index

  def index
    begin
      values = FactValue.my_facts.no_timestamp_facts.search_for(params[:search],:order => params[:order]).reorder('')
    rescue => e
      error e.to_s
      values = FactValue.no_timestamp_facts.search_for ""
    end
    @fact_values = values.required_fields.paginate :page => params[:page]
  end

end
