class FactsController < ApplicationController

  def index
    # we currently only support JSON in this controller
    return not_found unless api_request?

    render :json => FactName.no_timestamp_fact
  end

end
