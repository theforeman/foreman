module AuditHelper
  def created_at_column record
    record.created_at.to_s(:long)
  end

  def changes_column record
    record.changes.keys.map(&:humanize).to_sentence
  end

  def auditable_type_column record
   "a " + record.auditable_type.split("::")[-1]
  end

end
