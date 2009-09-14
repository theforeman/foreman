module ReportsHelper
  def entries_column record
    entry = record.log.logs.map{|entry| "%s %s" % [entry.source, entry.message]}.join("<br>")
    entry << "<br>See logfile for more details" if record.log.logs.size > 99
    entry
  end
end
