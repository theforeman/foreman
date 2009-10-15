class FactValuesController < ApplicationController
  before_filter :require_login, :except => :create

  active_scaffold :fact_value do |config|
    config.list.columns = [:fact_name, :value]
    config.actions = [:list]
    config.columns[:fact_name].clear_link
  end

  skip_before_filter :verify_authenticity_token
  include ExemptedFromLogging

  def create
    respond_to do |format|
      format.yml {
        if Host.importHostAndFacts params.delete("facts")
          render :text => "Imported facts", :status => 200 and return
        else
          render :text => "Failed to import facts", :status => 500
        end
      }
    end
  end

end
