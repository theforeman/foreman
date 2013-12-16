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
        Authorizer.new(User.current).find_collection(resource || self, permission)
      end
    }
  end
end
