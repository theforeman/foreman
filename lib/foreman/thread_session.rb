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
      def self.included(base)
        base.around_filter :clear_thread
      end

      def clear_thread
        if Thread.current[:user] && !Rails.env.test?
          Rails.logger.warn("Current user is set, but not expected. Clearing")
          Thread.current[:user] = nil
        end
        yield
      ensure
        [:user, :organization, :location].each do |key|
          Thread.current[key] = nil
        end
      end
    end

    # include this in the User model
    module UserModel
      def self.included(base)
        base.class_eval do
          def self.current
            Thread.current[:user]
          end

          def self.current=(o)
            unless o.nil? || o.is_a?(self)
              raise(ArgumentError, "Unable to set current User, expected class '#{self}', got #{o.inspect}")
            end

            Rails.logger.debug "Setting current user thread-local variable to " + (o.is_a?(User) ? o.login : 'nil')
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
          def self.as login
            old_user = current
            self.current = User.find_by_login(login)
            yield if block_given?
          ensure
            self.current = old_user
          end

          # returns a logout path for the user, useful for single sign on support
          #
          # it's being set when user logs into a foreman and it's meant to be an url of SSO system
          # logout page, it's appended by return url so it should contain a parameter at the end
          # e.g. "https://localhost/signo?return_url="
          def self.logout_path
            Thread.current[:logout_path] || ''
          end

          # sets a logout path to be used for a current user when logging out
          def self.logout_path=(path)
            Thread.current[:logout_path] = path
          end
        end
      end
    end

    # include this in the Organization model object
    module OrganizationModel
      def self.included(base)
        base.class_eval do
          def self.current
            Thread.current[:organization]
          end

          def self.current=(organization)
            unless organization.nil? || organization.is_a?(self) || organization.is_a?(Array)
              raise(ArgumentError, "Unable to set current organization, expected class '#{self}', got #{organization.inspect}")
            end

            Rails.logger.debug "Setting current organization thread-local variable to #{organization || "none"}"
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
          def self.as_org org
            old_org = current
            self.current = org
            yield if block_given?
          ensure
            self.current = old_org
          end
        end
      end
    end

    module LocationModel
      def self.included(base)
        base.class_eval do
          def self.current
            Thread.current[:location]
          end

          def self.current=(location)
            unless location.nil? || location.is_a?(self) || location.is_a?(Array)
              raise(ArgumentError, "Unable to set current location, expected class '#{self}'. got #{location.inspect}")
            end

            Rails.logger.debug "Setting current location thread-local variable to #{location || "none"}"
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
          def self.as_location location
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
end
