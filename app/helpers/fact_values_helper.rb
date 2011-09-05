module FactValuesHelper

  def fact_from record
    time_ago_in_words(record.host.last_compile) + " ago"
  rescue
    "N/A"
  end
end
