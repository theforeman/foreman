class NotificationType < ActiveRecord::Base
  AUDIENCE_USER     = 'user'.freeze
  AUDIENCE_GROUP    = 'usergroup'.freeze
  AUDIENCE_TAXONOMY = 'taxonomy'.freeze
  AUDIENCE_GLOBAL   = 'global'.freeze
  AUDIENCE_ADMIN    = 'admin'.freeze
  has_many :notifications
  validates :message, :presence => true
  validates :level, :inclusion => { :in => %w(success error warning info) }, :presence => true
  validates :audience, :inclusion => { :in => [AUDIENCE_USER, AUDIENCE_GROUP, AUDIENCE_TAXONOMY, AUDIENCE_GLOBAL, AUDIENCE_ADMIN] }, :presence => true
  validates :expires_in, :numericality => {:greater_than => 0}
  before_validation :set_default_expiry

  def subscriber_ids(initiator, subject = nil)
    case audience
    when AUDIENCE_GLOBAL
      User.reorder('').pluck(:id)
    when AUDIENCE_TAXONOMY
      subject.user_ids.uniq
    when AUDIENCE_USER
      [initiator.id]
    when AUDIENCE_ADMIN
      User.only_admin.reorder('').uniq.pluck(:id)
    when AUDIENCE_GROUP
      subject.all_users.uniq.map(&:id) # This needs to be rewritten in usergroups.
    end
  end

  private

  def set_default_expiry
    self.expires_in ||= 24.hours
  end
end
