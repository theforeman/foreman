class AuditController < ApplicationController

  active_scaffold :audit do |config|
    list.empty_field_text ='N/A'
    list.per_page = 15
    config.columns = [:auditable_type, :auditable, :action, :created_at, :username, :changes ]
    config.actions = [:list, :search]
    config.columns[:created_at].label = "Changed at"
    config.columns[:auditable_type].label = "Changed"
    config.list.sorting   = { :created_at => :desc }
    config.action_links.add 'show', :label => 'Details', :inline => false, :type => :record

  end

  def show
    @audit = Audit.find(params[:id])
  end
end
