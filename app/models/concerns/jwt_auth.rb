module JwtAuth
  extend ActiveSupport::Concern

  included do
    has_one :jwt_secret, inverse_of: :user, dependent: :destroy

    def jwt_secret!
      jwt_secret || create_jwt_secret!
    end

    # Arguments:
    # => :scope       Array of permissions, eg: [:view_hosts, :create_hosts]
    # => :expiration  Integer, eg: 4.hours.to_i
    def jwt_token!(scope: [], expiration: nil)
      jwt_secret = jwt_secret!
      JwtToken.encode(self, jwt_secret.token, scope: scope, expiration: expiration).to_s
    end
  end
end
