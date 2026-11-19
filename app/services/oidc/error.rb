module Oidc
  class Error < Foreman::Exception
  end

  class ConfigurationError < Error
  end

  class AuthenticationError < Error
  end
end
