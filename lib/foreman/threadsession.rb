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
            unless o.nil?
              if SETTINGS[:single_org] and not o.admin? and not o.organizations.empty? and not Thread.current[:organization]
                # default the org to the "first" org
                Thread.current[:organization] = o.organizations[0]
              end
            else
              Thread.current[:organization] = nil
            end
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
          def self.as(login, &do_block)
            old_user = current
            self.current = User.find_by_login(login)
            do_block.call
            self.current = old_user
          end
        end
      end
    end

    # include this in the Organization model object
    module TaxonomyModel
      def self.included(base)
        base.class_eval do
          def self.current
            if SETTINGS[:single_org]
              Thread.current[:taxonomy]
            elsif SETTINGS[:multi_org]
              User.current.taxonomies
            end
          end

          def self.current=(o)
            unless SETTINGS[:single_org]
              raise(ArgumentError, "Cannot set the current taxonomy unless SETTINGS[:single_org] is set to true")
            end
            unless o.nil? || o.is_a?(self)
              raise(ArgumentError, "Unable to set current taxonomy, expected class '#{self}', got #{o.inspect}")
            end
            unless User.current.admin?
              Rails.logger.debug "Setting current taxonomy thread-local variable to " + (o.is_a?(Taxonomy) ? o.name : 'nil')
              Thread.current[:taxonomy] = o
            end
          end
        end
      end
    end
  end
end
