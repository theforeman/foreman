module HostsHelper
  def last_compile_column(record)
    time_ago_in_words record.last_compile.getlocal unless record.last_compile.nil?
  end

end
