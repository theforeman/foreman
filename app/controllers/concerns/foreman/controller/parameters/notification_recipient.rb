module Foreman::Controller::Parameters::NotificationRecipient
  extend ActiveSupport::Concern

  class_methods do
    def notification_recipient_params_filter
      Foreman::ParameterFilter.new(::NotificationRecipient).tap do |filter|
        filter.permit :seen
      end
    end
  end

  def notification_recipient_params
    self.class.notification_recipient_params_filter.filter_params(params, parameter_filter_context)
  end
end
