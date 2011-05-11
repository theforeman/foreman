module UsersHelper
  def last_login_on_column record
    time_ago_in_words(record.last_login_on.getlocal) + " ago" if record.last_login_on
  end

  def auth_source_column record
    record.auth_source.to_label if record.auth_source
  end

  def contracted_host_list user
    content_tag(:span, :id => "contracted_host_list", :style => "display:inline;") do
      link_to_function("#{user.hosts[0..20].join(", ")}#{"..." if user.hosts.size > 20}") do |page|
        page[:contracted_host_list].hide
        page[:expanded_host_list].show
      end
    end
  end

  def expanded_host_list user
    content_tag(:span, :id => "expanded_host_list", :style => "display:none;") do
      link_to_function(user.hosts.to_sentence) do |page|
        page[:contracted_host_list].show
        page[:expanded_host_list].hide
      end
    end
  end

end
