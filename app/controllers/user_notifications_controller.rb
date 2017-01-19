class UserNotificationsController < Api::V2::BaseController
  before_action :require_login
  before_action :find_resource, :only => [:update, :destroy]

  def index
    @notifications = NotificationRecipient.
    where(:user_id => User.current.id).
    order(:created_at).
    eager_load(:notification, :notification_type)

    render :json => {
      :notifications => @notifications.paginate(paginate_options).map(&:payload),
      :total => @notifications.count
    }
  end

  def update
    # only allowed attribute to change is 'seen'
    process_response @user_notification.update_attribute(:seen, params[:user_notification][:seen])
  end

  def destroy
    process_response @user_notification.destroy
  end

  private

  def require_login
    not_found unless SETTINGS[:login]
  end

  def find_resource
    @user_notification = NotificationRecipient.where(:user_id => User.current.id, :id => params[:id]).first
    @user_notification || not_found
  end
end
