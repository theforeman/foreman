#
# In several cases we want to break chain of responsibility in MVC a bit and provide
# a safe way to access current user (and maybe few more data items). Storing it as
# a global variable (or class member) is not thread-safe. Including ThreadSession::
# UserModel in models and ThreadSession::Controller in the application controller
# allows this without any concurrent issues.
#
# Idea taken from sentinent_user rails plugin.
#
# http://github.com/bokmann/sentient_user
# http://github.com/astrails/let_my_controller_go
# http://rails-bestpractices.com/posts/47-fetch-current-user-in-models
#

module Foreman
  module ThreadSession
    # module to be include in controller to clear the session data
    # after (and evenutally before) the request processing.
    # Without it we're risking inter-users interference.
    module Cleaner
      extend ActiveSupport::Concern

      included do
        around_action :clear_thread
      end

      def clear_thread
        if Thread.current[:user] && !Rails.env.test?
          Foreman::Logging.logger('taxonomy').warn("Current user is set, but not expected. Clearing")
          Thread.current[:user] = nil
        end
        yield
      ensure
        [:user, :organization, :location].each do |key|
          Thread.current[key] = nil
        end
      end
    end

    # This allows getting and setting all current values in case it's needed,
    # for example to pass to an enumerator that is executed by a separate thread
    module Context
      def self.get
        {
          :user => User.current,
          :organization => Organization.current,
          :location => Location.current,
        }
      end

      def self.set(user: nil, organization: nil, location: nil)
        User.current = user
        Organization.current = organization
        Location.current = location
      end
    end

    # include this in the User model
    module UserModel
      extend ActiveSupport::Concern

      module ClassMethods
        def current
          Thread.current[:user]
        end

        def impersonator=(user)
          ::Logging.mdc['user_impersonator'] = user&.login
        end

        def current=(o)
          unless o.nil? || o.is_a?(self)
            raise(ArgumentError, "Unable to set current User, expected class '#{self}', got #{o.inspect}")
          end

          if o.is_a?(User)
            user = o.login
            type = o.admin? ? 'admin' : 'regular'
            if o.hidden?
              Foreman::Logging.logger('permissions').debug("Current user set to #{user} (#{type})")
            else
              Foreman::Logging.logger('permissions').info("Current user set to #{user} (#{type})")
            end
          end
          ::Logging.mdc['user_login'] = o&.login
          ::Logging.mdc['user_admin'] = o&.admin? || false
          Thread.current[:user] = o
        end

        # Executes given block on behalf of a different user. Example:
        #
        # User.as :admin do
        #   ...
        # end
        #
        # Use with care!
        #
        # @param [String] login to find from the database
        # @param [block] block to execute
        def as(login)
          old_user = current
          self.current = if login.is_a?(User)
                           login
                         else
                           User.unscoped.find_by_login(login)
                         end
          raise ::Foreman::Exception.new(N_("Cannot find user %s when switching context"), login) unless current.present?
          yield if block_given?
        ensure
          self.current = old_user
        end

        def as_anonymous_admin(&block)
          as User::ANONYMOUS_ADMIN, &block
        end
      end
    end

    # include this in the Organization model object
    module OrganizationModel
      extend ActiveSupport::Concern

      module ClassMethods
        def current
          Thread.current[:organization]
        end

        def current=(organization)
          unless organization.nil? || organization.is_a?(self) || organization.is_a?(Array)
            raise(ArgumentError, "Unable to set current organization, expected class '#{self}', got #{organization.inspect}")
          end

          Foreman::Logging.logger('taxonomy').debug "Current organization set to #{organization || 'none'}"
          org_id = organization.try(:id)
          org_name = organization.try(:name)
          org_label = organization.try(:label)
          ::Logging.mdc['org_id'] = org_id if org_id
          ::Logging.mdc['org_name'] = org_name if org_name
          ::Logging.mdc['org_label'] = org_label if org_label
          Thread.current[:organization] = organization
        end

        # Executes given block in the scope of an org:
        #
        # Organization.as_org organization do
        #   ...
        # end
        #
        # @param [org]
        # @param [block] block to execute
        def as_org(org)
          old_org = current
          self.current = org
          yield if block_given?
        ensure
          self.current = old_org
        end
      end
    end

    module LocationModel
      extend ActiveSupport::Concern

      module ClassMethods
        def current
          Thread.current[:location]
        end

        def current=(location)
          unless location.nil? || location.is_a?(self) || location.is_a?(Array)
            raise(ArgumentError, "Unable to set current location, expected class '#{self}'. got #{location.inspect}")
          end

          Foreman::Logging.logger('taxonomy').debug "Current location set to #{location || 'none'}"
          loc_id = location.try(:id)
          loc_name = location.try(:name)
          loc_label = location.try(:label)
          ::Logging.mdc['loc_id'] = loc_id if loc_id
          ::Logging.mdc['loc_name'] = loc_name if loc_name
          ::Logging.mdc['loc_label'] = loc_label if loc_label
          Thread.current[:location] = location
        end

        # Executes given block without the scope of a location:
        #
        # Location.as_location location do
        #   ...
        # end
        #
        # @param [location]
        # @param [block] block to execute
        def as_location(location)
          old_location = current
          self.current = location
          yield if block_given?
        ensure
          self.current = old_location
        end
      end
    end
  end
end
