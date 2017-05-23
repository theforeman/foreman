# frozen_string_literal: true

# Stores the information related to serving the notification to multiple users
# This class' responsibility is, given a notification blueprint, to determine
# who are the notification recipients
class Notification < ApplicationRecord
  AUDIENCE_USER     = 'user'
  AUDIENCE_GROUP    = 'usergroup'
  AUDIENCE_TAXONOMY = 'taxonomy'
  AUDIENCE_GLOBAL   = 'global'
  AUDIENCE_ADMIN    = 'admin'

  belongs_to :notification_blueprint
  belongs_to :initiator, :class_name => User, :foreign_key => 'user_id'
  belongs_to :subject, :polymorphic => true
  has_many :notification_recipients, :dependent => :delete_all
  has_many :recipients, :class_name => User, :through => :notification_recipients, :source => :user
  store :actions, :accessors => [:links], :coder => JSON

  validates :notification_blueprint, :presence => true
  validates :initiator, :presence => true
  validates :audience, :inclusion => {
    :in => [AUDIENCE_USER, AUDIENCE_GROUP, AUDIENCE_TAXONOMY,
            AUDIENCE_GLOBAL, AUDIENCE_ADMIN]
  }, :presence => true
  validates :message, :presence => true
  before_validation :set_custom_attributes
  before_create :set_expiry, :set_notification_recipients,
    :set_default_initiator

  scope :active, -> { where('notifications.expired_at >= :now', {:now => Time.now.utc}) }
  scope :expired, -> { where('notifications.expired_at < :now', {:now => Time.now.utc}) }

  def expired?
    Time.now.utc > expired_at
  end

  def subscriber_ids
    case audience
    when AUDIENCE_GLOBAL
      User.reorder('').pluck(:id)
    when AUDIENCE_TAXONOMY
      subject.user_ids.uniq
    when AUDIENCE_USER
      [initiator.id]
    when AUDIENCE_ADMIN
      User.only_admin.except_hidden.reorder('').uniq.pluck(:id)
    when AUDIENCE_GROUP
      subject.all_users.uniq.map(&:id) # This needs to be rewritten in usergroups.
    end
  end

  private

  # use timestamp definitions from blueprint and store the value in our model.
  def set_expiry
    self.expired_at = notification_blueprint.expired_at
  end

  def set_default_initiator
    self.initiator = User.anonymous_admin
  end

  def set_notification_recipients
    subscribers = subscriber_ids
    notification_recipients.build subscribers.map{|id| { :user_id => id}}
  end

  def set_custom_attributes
    return unless notification_blueprint # let validation catch this.
    self.actions = UINotifications::URLResolver.new(
      subject,
      notification_blueprint.actions
    ).actions if notification_blueprint.actions.any?
    # copy notification message in case we didn't create a custom one.
    self.message ||= UINotifications::StringParser.new(
      notification_blueprint.message,
      {subject: subject, initator: initiator}
    ).to_s
  end
end
