require 'pcptrace'

ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  controller = event.payload[:controller]
  action = event.payload[:action]
  format = event.payload[:format] || "all"
  format = "all" if format == "*/*"
  status = event.payload[:status]
  key = "#{controller}.#{action}.#{format}"
  r = PCPTrace::obs "#{key}.total_duration", event.duration
  Rails.logger.warn("Telemetry error: " + PCPTrace::errstr(r)) if r != 0
  PCPTrace::obs "#{key}.db_time", event.payload[:db_runtime]
  PCPTrace::obs "#{key}.view_time", (event.payload[:view_runtime] || 0)
  PCPTrace::counter "#{controller}.hit_#{status}", 1
  PCPTrace::counter "total.hit_#{status}", 1
end

ActiveSupport::Notifications.subscribe /instantiation.active_record/ do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  class_name = event.payload[:class_name]
  record_count = event.payload[:record_count]
  PCPTrace::counter "instantiation.#{class_name}", record_count
end

ActiveSupport::Notifications.subscribe /deliver.action_mailer/ do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  to = event.payload[:to].gsub(/[^0-9a-z ]/i, '_')
  PCPTrace::counter "mail_delivery.#{to}", 1
end
