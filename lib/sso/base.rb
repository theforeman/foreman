class Sso
  class Base
    attr_reader :request, :controller
    attr_accessor :user

    def initialize(controller)
      @controller = controller
      @request = controller.request
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