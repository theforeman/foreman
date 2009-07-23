module HostsHelper
  def last_compile_column(record)
    time_ago_in_words record.last_compile unless record.last_compile.nil?
  end

end
