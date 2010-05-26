module AuditsHelper

  # lookups the Model repesenting the numerical id and return its label
  def id_to_label name, change
    model = (eval name.humanize)
    model.find(change).to_label
  rescue
    "N/A"
  end

  def audit_title audit
    audit.try(:auditable).try(:to_label)
  end

  def auditable_type audit
    audit.auditable_type.split("::").last
  end

  def change_order action, value
    output = ["N/A", value]
    output.reverse! if action == "destroy"
    output
  end

end
