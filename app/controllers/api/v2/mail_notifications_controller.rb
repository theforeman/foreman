module Api
  module V2
    class MailNotificationsController < V2::BaseController
      include Api::Version2

      before_filter :find_resource, :only => %w{show}

      api :GET, "/mail_notifications/", N_("List of mail notifications")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @mail_notifications = MailNotification.
          authorized(:view_mail_notifications).
          subscriptable.
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/mail_notifications/:id/", N_("Show a mail notification")
      param :id, :identifier, :required => true, :desc => N_("Numerical ID or mail notification name")

      def show
      end
    end
  end
end
