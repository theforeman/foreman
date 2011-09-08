class FactsController < ApplicationController
  before_filter :valid_request?

  def index
    render :json => FactName.no_timestamp_fact
  end

  def show
    @fact = FactName.find(params[:id])
    begin
      data = {:name => @fact.name, :values => FactValue.count_each(@fact.name).to_a }
    rescue
      data = @fact
    end
    render :json => data
  end

  private

  # we currently only support JSON in this controller
  def valid_request?
    return not_found unless api_request?
  end

end
