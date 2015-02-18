module TasksHelper
  def task_status(status)
    icon = case status
             when "completed"
               "check"
             when "running"
               "refresh"
             when "failed"
               "remove"
             when "rollbacked"
               "fast-backward"
             when "pending"
               "th"
             when "canceled"
               "ban-circle"
             else
               "th"
           end
    icon_text(icon, status)
  end
end
