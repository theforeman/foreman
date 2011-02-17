module UsersHelper
  def last_login_on_column record
    time_ago_in_words(record.last_login_on.getlocal) + " ago" if record.last_login_on
  end

  def auth_source_column record
    record.auth_source.to_label if record.auth_source
  end
end
