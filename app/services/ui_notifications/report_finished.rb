# frozen_string_literal: true

module UINotifications
  class ReportFinished < UINotifications::Base
    include Rails.application.routes.url_helpers

    def initialize(composer, job_id)
      super(User.current)

      @composer = composer
      @job_id = job_id
      @template = composer.template
    end

    private

    def create
      add_notification
    end

    def update_notifications
      blueprint.notifications.
          where(subject: subject).
          update_all(expired_at: blueprint.expired_at)
    end

    def add_notification
      Notification.create!(
        initiator: initiator,
        audience: ::Notification::AUDIENCE_USER,
        subject: subject,
        message: N_('Report "%s" is ready to download') % @template.name,
        notification_blueprint: blueprint,
        links: [
          {
            title: N_('Download Report'),
            href: report_data_report_template_path(@template, job_id: @job_id),
          },
          {
            title: N_('Regenerate Report'),
            href: generate_report_template_path(@template, { report_template_report: { input_values: @composer.to_params[:input_values] } }),
          },
        ]
      )
    end

    def blueprint
      @blueprint ||= NotificationBlueprint.find_by(name: 'report_finish')
    end
  end
end
