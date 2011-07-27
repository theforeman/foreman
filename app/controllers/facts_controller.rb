class FactsController < ApplicationController

  def index
    # we currently only support JSON in this controller
    return not_found unless request_json?

    render :json => Puppet::Rails::FactName.all(:select => "name", :conditions => ["fact_names.name <> ?",:timestamp])
  end

end
