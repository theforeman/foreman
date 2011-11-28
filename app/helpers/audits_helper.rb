module AuditsHelper

  # lookups the Model repesenting the numerical id and return its label
  def id_to_label name, change
    model = (eval name.humanize)
    model.find(change).to_label
  rescue
    "N/A"
  end

  def audit_title audit
    audit.try(:auditable).try(:name)
  end

  def audit_parent audit
    audit.try(:associated).try(:name)
  end

  def association_type audit
    audit.association_type.split("::").last if audit.association_type
  end

  def change_order action, value
    output = ["N/A", value]
    output.reverse! if action == "destroy"
    output
  end

  def changes_column changes
    msg = changes.keys.map(&:humanize).to_sentence if changes.is_a?(Hash)
    msg ||=changes
    return truncate(msg, :length => 50)
  end

end
