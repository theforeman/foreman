class NotificationRecipientsController < Api::V2::BaseController
  include Foreman::Controller::Parameters::NotificationRecipient
  skip_before_action :update_activity_time, :only => [:index]
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

  def update_group_as_read
    count = NotificationRecipient.
      joins(:notification_blueprint).
      where(user_id: User.current.id, seen: false,
        notification_blueprints: { group: params[:group]}).
      update_all(seen: true)

    logger.debug("updated #{count} notification recipents as seen for group #{params[:group]}")
    UINotifications::CacheHandler.new(User.current.id).clear unless count.zero?

    head status: (count.zero? ? :not_modified : :ok)
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
