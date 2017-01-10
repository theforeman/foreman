class NotificationRecipientsController < Api::V2::BaseController
  include Foreman::Controller::Parameters::NotificationRecipient

  before_action :require_login
  before_action :find_resource, :only => [:update, :destroy]

  def index
    @notifications = NotificationRecipient.
      where(:user_id => User.current.id).
      order(:created_at).
      eager_load(:notification, :notification_blueprint)

    render :json => {
      :notifications => @notifications.paginate(paginate_options).map(&:payload),
      :total => @notifications.count
    }
  end

  def update
    process_response @notification_recipient.update_attributes(notification_recipient_params)
  end

  def destroy
    process_response @notification_recipient.destroy
  end

  private

  def require_login
    not_found unless SETTINGS[:login]
  end

  def find_resource
    super
    @notification_recipient.current_user? || not_found
  end
end
