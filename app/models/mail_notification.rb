class MailNotification < ActiveRecord::Base
  include Authorizable

  INTERVALS = %w(daily weekly monthly)

  attr_accessible :description, :title, :mailer, :method, :name, :default_interval,
                  :subscriptable

  has_many :user_mail_notifications, :dependent => :destroy
  has_many :users, :through => :user_mail_notifications

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :title, :complete_value => true
  scoped_search :on => :description, :complete_value => true
  scoped_search :in => :users, :on => :login, :complete_value => true, :rename => :user

  scope :subscriptable, lambda { where(:subscriptable => true) }

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true, :uniqueness => true
  validates :default_interval, :inclusion => { :in => INTERVALS }, :allow_blank => true
  validates :mailer, :presence => true
  validates :method, :presence => true

  default_scope lambda {
    order("mail_notifications.name")
  }

  # Easy way to reference the notification to support something like:
  #   MailNotification[:some_error_notification].deliver(options)
  def self.[](title)
    self.find_by_title(title)
  end

  def deliver(options)
    mailer.constantize.send(method, options).deliver
  rescue => e
    logger.warn "Failed to send email notification #{title}: #{e}"
    logger.debug e.backtrace
  end
end
