class MailNotification < ApplicationRecord
  include Authorizable

  INTERVALS = [N_("Daily"), N_("Weekly"), N_("Monthly")]
  SUBSCRIPTION_TYPES = %w(alert report)

  has_many :user_mail_notifications, :dependent => :destroy
  has_many :users, :through => :user_mail_notifications

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :description, :complete_value => true
  scoped_search :relation => :users, :on => :login, :complete_value => true, :rename => :user

  scope :subscriptable, -> { where(:subscriptable => true) }

  validates :name, :presence => true, :uniqueness => true
  validates :subscription_type, :inclusion => { :in => SUBSCRIPTION_TYPES }, :allow_blank => true
  validates :mailer, :presence => true
  validates :method, :presence => true
  alias_attribute :mailer_method, :method

  default_scope -> { order("mail_notifications.name") }

  def initialize(*args)
    params = args.shift
    if params.is_a?(Hash) && params[:name] == 'config_error_state'
      params[:type] = "ConfigManagementError"
    end
    args.unshift(params)
    super(*args)
  end

  # Easy way to reference the notification to support something like:
  #   MailNotification[:some_error_notification].deliver(options)
  def self.[](name)
    find_by_name(name.to_s)
  end

  def subscription_options
    [N_("Subscribe")]
  end

  def deliver(*args)
    # args can be anything really, treat it carefully
    # handle args=[.., :users => [..]] specially and instantiate a single mailer per user, with :user set on each
    if args.last.is_a?(Hash) && args.last.has_key?(:users)
      options = args.pop
      options.delete(:users).each do |user|
        mailer.constantize.send(method, *args, options.merge(:user => user)).deliver_now
      end
    else
      mailer.constantize.send(method, *args).deliver_now
    end
  end
end
