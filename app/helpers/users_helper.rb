module UsersHelper
  def last_login_on_column record
    _("%s ago") % time_ago_in_words(record.last_login_on.getlocal) if record.last_login_on
  end

  def auth_source_column record
    record.auth_source.to_label if record.auth_source
  end

  def contracted_host_list user
    content_tag(:span, :id => "contracted_host_list", :style => "display:inline;") do
      content_tag(:span, user.hosts.to_sentence)
    end
  end

  def expanded_host_list user
    content_tag(:span, :id => "expanded_host_list", :style => "display:none;") do
    end
  end

end
