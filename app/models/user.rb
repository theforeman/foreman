class User < ActiveRecord::Base
  belongs_to :auth_source
  has_many :changes, :class_name => 'Audit', :as => :user

  has_many :hosts

  validates_uniqueness_of :login, :message => "already exists"
  validates_presence_of :login, :mail
  validates_format_of :login, :with => /^[a-z0-9_\-@\.]*$/i
  validates_length_of :login, :maximum => 30
  validates_format_of :firstname, :lastname, :with => /^[\w\s\'\-\.]*$/i, :allow_nil => true
  validates_length_of :firstname, :lastname, :maximum => 30, :allow_nil => true
  validates_format_of :mail, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_nil => true
  validates_length_of :mail, :maximum => 60, :allow_nil => true

  def to_label
    "#{firstname} #{lastname}"
  end

  def self.try_to_login(login, password)
    # Make sure no one can sign in with an empty password
    return nil if password.to_s.empty?
    if user = find(:first, :conditions => ["login=?", login])
      # user is already in local database
      if user.auth_source
        # user has an external authentication method
        return nil unless user.auth_source.authenticate(login, password)
      else
        # TODO: Add support for local password authentication
        return nil
      end
    else
      # user is not yet registered, try to authenticate with available sources
      attrs = AuthSource.authenticate(login, password)
      if attrs
        user = new(*attrs)
        user.login = login
        if user.save
          user.reload
          logger.info("User '#{user.login}' created from the LDAP") if logger
        else
          logger.info("Failed to save User '#{user.login}' #{user.errors.full_messages}") if logger
        end
      end
    end
    user.update_attribute(:last_login_on, Time.now.utc) if user && !user.new_record?
    user
  rescue => text
    raise text
  end

end
