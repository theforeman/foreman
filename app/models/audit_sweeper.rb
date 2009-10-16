class AuditSweeper < ActionController::Caching::Sweeper
  observe Host

  def after_destroy(record)
    log(record, "DESTROY")
  end

  def after_update(record)
    log(record, "UPDATE")
  end

  def after_create(record)
    log(record, "CREATE")
  end

  def log(record, event)
    # if we are using one of the importers, uid is -1
    user = (controller.nil? or u =controller.session[:user].nil?) ? -1 : u

    AuditTrail.create(:record_id => record.id,
                      :record_type => record.type.name,
                      :event => event,
                      :description => record.to_s,
                      :user_id => user)
  end
end

