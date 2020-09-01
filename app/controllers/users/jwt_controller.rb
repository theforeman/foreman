module Users
  class JwtController < ApplicationController
    def create
      render json: { jwt: User.current.jwt_token!(expiration: expiration) }
    end

    private

    def expiration
      value = params[:expiration_value].to_i
      unit = params[:expiration_unit]

      return nil if value == 0 || unit == 'never'
      value.send(unit).to_i
    end
  end
end
