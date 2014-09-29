module Authorizable
  extend ActiveSupport::Concern

  included do
    # permission can be nil (therefore we use Proc instead of lambda)
    # same applies for resource class
    #
    # e.g.
    #   FactValue.authorized_as(user)
    #   FactValue.authorized_as(user, :view_facts)
    #   Host::Base.authorized_as(user, :view_hosts, Host)
    #
    # Or you may simply use authorized for User.current
    #
    scope :authorized_as, Proc.new { |user, permission, resource|
      if user.nil?
        self.where('1=0')
      elsif user.admin?
        self.scoped
      else
        Authorizer.new(user).find_collection(resource || self, :permission => permission)
      end
    }

    def self.authorized(permission = nil, resource = nil)
      self.authorized_as(User.current, permission, resource)
    end

    def authorized?(permission)
      return false if User.current.nil?
      User.current.can?(permission, self)
    end
  end

  module ClassMethods
    def allows_taxonomy_filtering?(taxonomy)
      scoped_search_definition.fields.has_key?(taxonomy)
    end

    def allows_organization_filtering?
      allows_taxonomy_filtering?(:organization_id)
    end

    def allows_location_filtering?
      allows_taxonomy_filtering?(:location_id)
    end
  end
end
