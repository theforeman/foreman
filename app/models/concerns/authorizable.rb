module Authorizable
  extend ActiveSupport::Concern

  included do
    # permission can be nil (therefore we use Proc instead of lambda)
    # same applies for resource class
    #
    # e.g.
    #   FactValue.authorized
    #   FactValue.authorized(:view_facts)
    #   Host::Base.authorized(:view_hosts, Host)
    #
    scope :authorized, Proc.new { |permission, resource|
      if User.current.nil?
        self.where('1=0')
      elsif User.current.admin?
        self.scoped
      else
        Authorizer.new(User.current).find_collection(resource || self, :permission => permission)
      end
    }

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
