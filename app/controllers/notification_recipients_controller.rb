class NotificationRecipientsController < Api::V2::BaseController
  include Foreman::Controller::Parameters::NotificationRecipient
  skip_before_action :update_activity_time, :only => [:index]
  before_action :find_resource, :only => [:update, :destroy]

  def index
    payload = UINotifications::CacheHandler.new(User.current.id).payload
    redux_action(notification_action(payload))
    render :json => payload
  end

  def update
    process_response @notification_recipient.update(notification_recipient_params),
      redux_action(notification_action(UINotifications::CacheHandler.new(User.current.id).payload))
  end

  def destroy
    process_response @notification_recipient.destroy,
      redux_action(notification_action(UINotifications::CacheHandler.new(User.current.id).payload))
  end

  def update_group_as_read
    count = NotificationRecipient.
      joins(:notification_blueprint).
      where(user_id: User.current.id, seen: false,
        notification_blueprints: { group: params[:group]}).
      update_all(seen: true)

    logger.debug("updated #{count} notification recipents as seen for group #{params[:group]}")
    ui_notifications = UINotifications::CacheHandler.new(User.current.id)
    ui_notifications.clear unless count.zero?
    redux_action(notification_action(ui_notifications.payload))
    head (count.zero? ? :not_modified : :ok)
  end

  def destroy_group
    count = NotificationRecipient.
      joins(:notification_blueprint).
      where(user_id: User.current.id,
            notification_blueprints: { group: params[:group]}).
      delete_all

    logger.debug("deleted #{count} notification recipents for group #{params[:group]}")
    ui_notifications = UINotifications::CacheHandler.new(User.current.id)
    ui_notifications.clear unless count.zero?
    redux_action(notification_action(ui_notifications.payload))
    head (count.zero? ? :not_modified : :ok)
  end

  private

  def find_resource
    super
    @notification_recipient.current_user? || not_found
  end

  def notification_action(payload)
    { type: 'SERVER_NOTIFICATIONS', payload: JSON.parse(payload) }
  end
end
