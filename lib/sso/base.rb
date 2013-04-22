module SSO
  class Base
    attr_reader :controller
    attr_accessor :user
    delegate :request, :to => :controller

    def initialize(controller)
      @controller = controller
    end

    def support_login?
      false
    end

    def support_logout?
      false
    end

    def authenticated?
      raise NotImplemented, 'authenticated? not implemented for this authentication method'
    end

    def authenticate!
      raise NotImplemented, 'authenticate! not implemented for this authentication method'
    end
  end
end