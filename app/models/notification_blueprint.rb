# Model to store all information related to a notification.
# The audience for this notification is calculated on real time by
# Notification.
#
# Foreman and plugins should define NotificationBlueprints for various
# actions that are notification-worthy. This keeps the responsibilities
# separate, Notifications taking care of serving the content, and
# NotificationBlueprint of storing it.
class NotificationBlueprint < ActiveRecord::Base
  has_many :notifications
  belongs_to :subject, :polymorphic => true

  validates :message, :presence => true
  validates :group, :presence => true
  validates :name, :presence => true
  validates :level, :inclusion => { :in => %w(success error warning info) }, :presence => true
  validates :expires_in, :numericality => {:greater_than => 0}
  before_validation :set_default_expiry

  private

  def set_default_expiry
    self.expires_in ||= 24.hours
  end
end
