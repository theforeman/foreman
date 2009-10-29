module AuditHelper
  def created_at_column record
    record.created_at.to_s(:long)
  end

  def changes_column record
    record.changes.keys.map(&:humanize).to_sentence
  end

  def auditable_type_column record
    record.auditable_type.split("::")[-1]
  end

  # return nil or the object name that was audited
  def auditable record
    begin
      return record.auditable.to_label
    rescue
    end
  end

  # lookups the Model repesenting the numerical id and return its label
  def id_to_label name, change
    (eval name.humanize).find(change).to_label
  end


end
