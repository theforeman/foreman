module HostsHelper
  def last_compile_column(record)
    time_ago_in_words record.last_compile.getlocal unless record.last_compile.nil?
  end
  def root_pass_form_column(record, field_name)
      password_field_tag field_name, record.root_pass
  end


end
