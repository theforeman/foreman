module UsersHelper
  def last_login_on_column record
    time_ago_in_words(record.last_login_on.getlocal) if record.last_login_on
  end

  def admin_column record
    image_tag("true.png", :size => "18x18") if record.admin
  end
end
