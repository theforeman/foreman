module FactValuesHelper

  def fact_from record
    time_ago_in_words(Time.parse(@timestamps.select{|fv| fv.host_id == record.host_id}.first.value).utc) + " ago"
  rescue
    "N/A"
  end
end
