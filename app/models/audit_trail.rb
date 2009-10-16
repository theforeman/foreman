class AuditTrail < ActiveRecord::Base

  def before_update
    raise ActiveRecord::ReadOnlyRecord
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end

end
