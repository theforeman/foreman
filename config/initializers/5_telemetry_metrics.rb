# Foreman telemetry metrics registration.
#
# There are three types of telemetry measurements: counter, gauge, histogram. Each measurement has unique name
# represented by a symbol, a description and list of tags which are required and mapped to monitoring frameworks
# which do not support arbitrary tags.
#
# Plugins can add own metrics through add_counter_telemetry, add_gauge_telemetry and add_histogram_telemetry.
#
telemetry = Foreman::Telemetry.instance
telemetry.add_counter(:http_requests, 'A counter of HTTP requests made', [:controller, :action])
telemetry.add_histogram(:http_request_total_duration, 'Total duration of controller action', [:controller, :action])
telemetry.add_histogram(:http_request_db_duration, 'Time spent in database for a request', [:controller, :action])
telemetry.add_histogram(:http_request_view_duration, 'Time spent in view for a request', [:controller, :action])
telemetry.add_counter(:activerecord_instances, 'Number of instances of ActiveRecord models', [:class])
telemetry.add_counter(:successful_ui_logins, 'Number of successful logins in total')
telemetry.add_counter(:failed_ui_logins, 'Number of failed logins in total')
telemetry.add_counter(:bruteforce_locked_ui_logins, 'Number of blocked logins via bruteforce protection')
telemetry.add_histogram(:proxy_api_duration, 'Time spent waiting for Proxy (ms)', [:method])
telemetry.add_counter(:proxy_api_response_code, 'Number of Proxy API responses per HTTP code', [:code])
