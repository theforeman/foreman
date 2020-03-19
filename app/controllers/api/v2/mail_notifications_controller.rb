module Api
  module V2
    class MailNotificationsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::UserMailNotification

      before_action :find_resource, :only => %w{show}

      api :GET, "/mail_notifications/", N_("List of email notifications")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(MailNotification)

      def_param_group :user_mail_notification_params do
        param :user_id, String, :required => true
        param :mail_notification_id, Integer, :required => true
        param :interval, String, :desc => N_("Mail notification interval option, e.g. Daily, Weekly or Monthly. Required for summary notification")
        param :subscription, String, :desc => N_("Mail notification subscription option, e.g. Subscribe, Subscribe to my hosts or Subscribe to all hosts. Required for host built and config error state")
        param :mail_query, String, :required => false, :desc => N_("Relevant only for audit summary notification")
      end

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

      api :POST, "/users/:user_id/mail_notifications", N_("Add an email notification for a user")
      param_group :user_mail_notification_params

      def create
        @user = User.find(params[:user_id])
        validate_params params[:mail_notification_id]
        user_mail_notification = @user.user_mail_notifications.find { |mail_notification| mail_notification.mail_notification_id == params[:mail_notification_id] }
        if user_mail_notification.nil?
          mail_notifications_params = {'interval' => params[:interval].nil? ? params[:subscription].capitalize : params[:interval].capitalize,
                                       'mail_notification_id' => params[:mail_notification_id],
                                       'user_id' => params[:user_id],
                                       'mail_query' => params[:mail_query]}
          user_mail_notification = UserMailNotification.new(mail_notifications_params)
        else
          raise ::Foreman::Exception.new(N_("User mail notification already exists. Use the update action"))
        end
        @user.user_mail_notifications << user_mail_notification
        user_mail_notification
      end

      api :PUT, "/users/:user_id/mail_notifications/:mail_notification_id", N_("Update an email notification for a user")
      param_group :user_mail_notification_params

      def update
        @user = User.find(params[:user_id])
        validate_params params[:id]
        user_mail_notification = @user.user_mail_notifications.find { |mail_notification| mail_notification.mail_notification_id == params[:id].to_i }
        if user_mail_notification.nil?
          raise ::Foreman::Exception.new(N_("No user mail notification to update. Use the create action"))
        else
          user_mail_notification[:interval] = params[:interval].nil? ? params[:subscription].capitalize : params[:interval].capitalize
          user_mail_notification[:mail_query] = params[:mail_query]
        end
        @user.user_mail_notifications << user_mail_notification
        user_mail_notification
      end

      api :DELETE, "/users/:user_id/mail_notifications/:mail_notification_id", N_("Remove an email notification for a user")
      param :user_id, String, :required => true
      param :mail_notification_id, Integer, :required => true

      def destroy
        @user = User.find(params[:user_id])
        if @user == User.current || User.current.admin?
          notification = @user.mail_notifications.find(params[:id])
          @user.mail_notifications.delete(notification)
        else
          deny_access N_("You do not have permission to delete a mail notification of another user")
        end
      end

      api :GET, "/users/:user_id/mail_notifications/", N_("List all email notifications for a user")
      param :user_id, String, :required => true

      def user_mail_notifications
        @user = User.find(params[:id])
        @user_mail_notifications = @user.user_mail_notifications.map do |user_mail_notification|
          mail_notification = @user.mail_notifications.find { |mail_notification| mail_notification.id == user_mail_notification.mail_notification_id }
          user_mail_notification.attributes.merge('name' => mail_notification.name, 'description' => mail_notification.description)
        end
        render :json => @user_mail_notifications.as_json
      end

      private

      def validate_params(mail_notification_id)
        mail_notification = MailNotification.find(mail_notification_id)
        raise ::Foreman::Exception.new(N_("Interval or subscription option is missing")) if params[:interval].nil? && params[:subscription].nil?
        deny_access N_("You do not have permission to add a mail notification to another user") unless @user == User.current || User.current.admin?
        raise ::Foreman::Exception.new(N_("Interval option is needed")) if mail_notification.subscription_type == 'report' && params[:interval].nil?
        raise ::Foreman::Exception.new(N_("Subscription option is needed")) if mail_notification.subscription_type == 'alert' && params[:subscription].nil?
        subscription_options = mail_notification.subscription_options
        interval_options = mail_notification.subscription_type == 'alert' ? mail_notification.subscription_options : MailNotification::INTERVALS
        raise ::Foreman::Exception.new(N_("Interval option is not valid")) unless params[:interval].nil? || interval_options.include?(params[:interval].capitalize)
        raise ::Foreman::Exception.new(N_("Subscription option is not valid")) unless params[:subscription].nil? || subscription_options.include?(params[:subscription].capitalize)
        raise ::Foreman::Exception.new(N_("Mail query is not valid")) unless params[:mail_query].nil? || mail_notification.queryable?
      end
    end
  end
end
