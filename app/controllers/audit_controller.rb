class AuditController < ApplicationController
  active_scaffold :audit do |config|
    list.empty_field_text ='N/A'
    list.per_page = 15
    config.list.columns = [:auditable, :action, :created_at, :username, :auditable_type, :changes ]
    config.actions = [:show, :list, :search]
    config.columns[:created_at].label = "Changed at"
    config.columns[:auditable_type].label = "Changed"

  end

end
