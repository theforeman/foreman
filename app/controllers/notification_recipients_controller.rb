class NotificationRecipientsController < Api::V2::BaseController
  include Foreman::Controller::Parameters::NotificationRecipient

  before_action :require_login
  before_action :find_resource, :only => [:update, :destroy]

  def index
    payload = UINotifications::CacheHandler.new(User.current.id).payload
    render :json => payload
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
