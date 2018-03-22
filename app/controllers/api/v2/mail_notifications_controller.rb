module Api
  module V2
    class MailNotificationsController < V2::BaseController
      include Api::Version2

      before_action :find_resource, :only => %w{show}

      api :GET, "/mail_notifications/", N_("List of email notifications")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(MailNotification)

      def index
        @mail_notifications = MailNotification.
          authorized(:view_mail_notifications).
          subscriptable.
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/mail_notifications/:id/", N_("Show an email notification")
      param :id, :identifier, :required => true, :desc => N_("Numerical ID or email notification name")

      def show
      end
    end
  end
end
