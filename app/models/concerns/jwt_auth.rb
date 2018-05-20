module JwtAuth
  extend ActiveSupport::Concern

  included do
    has_one :jwt_secret, inverse_of: :user, dependent: :destroy

    def jwt_secret!
      jwt_secret || create_jwt_secret!
    end

    def jwt_token!
      jwt_secret = jwt_secret!
      JwtToken.encode(self, jwt_secret.token).to_s
    end
  end
end
