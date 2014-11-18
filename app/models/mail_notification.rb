class MailNotification < ActiveRecord::Base
  include Authorizable
  include SearchScope::MailNotification

  INTERVALS = [N_("Daily"), N_("Weekly"), N_("Monthly")]
  SUBSCRIPTION_TYPES = %w(alert report)

  attr_accessible :description, :mailer, :method, :name, :subscriptable, :subscription_type, :category

  has_many :user_mail_notifications, :dependent => :destroy
  has_many :users, :through => :user_mail_notifications

  scope :subscriptable, lambda { where(:subscriptable => true) }

  validates :name, :presence => true, :uniqueness => true
  validates :subscription_type, :inclusion => { :in => SUBSCRIPTION_TYPES }, :allow_blank => true
  validates :mailer, :presence => true
  validates :method, :presence => true
  alias_attribute :mailer_method, :method

  default_scope lambda {
    order("mail_notifications.name")
  }

  # Easy way to reference the notification to support something like:
  #   MailNotification[:some_error_notification].deliver(options)
  def self.[](name)
    self.find_by_name(name)
  end

  def deliver(options)
    mailer.constantize.send(method, options).deliver
  rescue => e
    logger.warn "Failed to send email notification #{name}: #{e}"
    logger.debug e.backtrace
  end
end
