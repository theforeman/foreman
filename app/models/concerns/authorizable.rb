module Authorizable
  extend ActiveSupport::Concern

  included do
    # permission can be nil (therefore we use Proc instead of lambda)
    scope :authorized, Proc.new { |permission|
      if User.current.nil?
        self.where('1=0')
      elsif User.current.admin?
        self.scoped
      else
        Authorizer.new(User.current).find_collection(self, permission)
      end
    }
  end
end
