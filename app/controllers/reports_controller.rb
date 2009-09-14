class ReportsController < ApplicationController
  active_scaffold :reports do |config|
    config.label   = "Puppet reports"
    config.actions = [:list, :search, :show]
    config.columns = [:host, :reported_at, :failed, :failed_restarts, :skipped, :entries]
    list.sorting   = {:host => 'ASC', :reported_at => "ASC" }
  end

  skip_before_filter :verify_authenticity_token

  def create
    respond_to do |format|
      format.yml {
        if Report.import params.delete("report")
          render :text => "Imported report", :status => 200 and return
        else
          render :text => "Failed to import report", :status => 500
        end
      }
    end
  end
end
