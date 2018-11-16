# Override "Processing by" logging method because Rails devs are opinionated
# about this: https://github.com/rails/rails/pull/26025 and we can't simply
# send "Parameters" line into INFO log level because of Katello and OpenSCAP
# very noisy endpoints leading to tens of gigabytes log file per day.
#
# Our own customized log subscriber logs all "Parameters" via DEBUG log level
# so users can decide when they want to see them. Prior attaching we need
# to unsubscribe all from start_processing.action_controller event as Rails
# API does not provide a way of unsubscribing an event for a particular subscriber.
#
ActiveSupport::Notifications.unsubscribe "start_processing.action_controller"
ActiveSupport::LogSubscriber.log_subscribers.select { |ls| ls.instance_of? ActionController::LogSubscriber }.first.patterns.delete("start_processing.action_controller")
Foreman::CustomizedLogSubscriber.attach_to :action_controller
