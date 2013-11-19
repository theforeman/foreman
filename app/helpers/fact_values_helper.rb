module FactValuesHelper

  def fact_from record
    _("%s ago") % time_ago_in_words(record.system.last_compile)
  rescue
    _("N/A")
  end
end
