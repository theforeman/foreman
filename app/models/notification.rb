# frozen_string_literal: true

# Stores the information related to serving the notification to multiple users
# This class' responsibility is, given a notification blueprint, to determine
# who are the notification recipients
class Notification < ActiveRecord::Base
  AUDIENCE_USER     = 'user'
  AUDIENCE_GROUP    = 'usergroup'
  AUDIENCE_TAXONOMY = 'taxonomy'
  AUDIENCE_GLOBAL   = 'global'
  AUDIENCE_ADMIN    = 'admin'

  belongs_to :notification_blueprint
  belongs_to :initiator, :class_name => User, :foreign_key => 'user_id'
  has_many :notification_recipients, :dependent => :delete_all
  has_many :recipients, :class_name => User, :through => :notification_recipients, :source => :user

  validates :notification_blueprint, :presence => true
  validates :initiator, :presence => true
  validates :audience, :inclusion => {
    :in => [AUDIENCE_USER, AUDIENCE_GROUP, AUDIENCE_TAXONOMY,
            AUDIENCE_GLOBAL, AUDIENCE_ADMIN]
  }, :presence => true
  before_create :calculate_expiry, :set_notification_recipients,
    :set_default_initiator

  scope :active, -> { where('expired_at >= :now', {:now => Time.now.utc}) }
  scope :expired, -> { where('expired_at < :now', {:now => Time.now.utc}) }

  def expired?
    Time.now.utc > expired_at
  end

  def subscriber_ids
    case audience
    when AUDIENCE_GLOBAL
      User.reorder('').pluck(:id)
    when AUDIENCE_TAXONOMY
      notification_blueprint.subject.user_ids.uniq
    when AUDIENCE_USER
      [initiator.id]
    when AUDIENCE_ADMIN
      User.only_admin.reorder('').uniq.pluck(:id)
    when AUDIENCE_GROUP
      notification_blueprint.subject.all_users.uniq.map(&:id) # This needs to be rewritten in usergroups.
    end
  end

  private

  def calculate_expiry
    self.expired_at = Time.now.utc + notification_blueprint.expires_in
  end

  def set_default_initiator
    self.initiator = User.anonymous_admin
  end

  def set_notification_recipients
    subscribers = subscriber_ids
    notification_recipients.build subscribers.map{|id| { :user_id => id}}
  end
end
