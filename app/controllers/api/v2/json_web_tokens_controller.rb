module Api
  module V2
    class JsonWebTokensController < V2::BaseController
      include Api::Version2

      before_action :find_user

      api :POST, "/users/:id/json_web_tokens", N_("Generate JSON web token")
      param :id, String, required: true, desc: N_("User id")
      param :expires_at, DateTime, desc: N_("Expiration date of the token. If not set, token will never expire")
      def create
        render json: { json_web_token: @user.jwt_token!(expiration: expires_at) }
      end

      api :DELETE, "/users/:id/json_web_tokens", N_("Invalidates all user's JSON web tokens")
      param :id, String, required: true, desc: N_("User id")
      def destroy
        jwt_secret = @user.jwt_secret
        message = _("JSON web tokens successfully invalidated")

        return render_message(message) unless jwt_secret

        if jwt_secret.destroy
          render_message(message)
        else
          message = _("Could not invalidate JSON web tokens, see the application log for more information")
          render_error :custom_error, status: :unprocessable_entity, locals: { message: message }
        end
      end

      def resource_class
        User
      end

      private

      def expires_at
        return unless params[:expires_at]
        Time.zone.parse(params[:expires_at]).utc.to_i - Time.now.utc.to_i
      end

      def find_user
        editing_self = User.current.editing_self?(params)
        @user = editing_self ? User.current : User.authorized(:edit_users).except_hidden.find(params[:id])
      end
    end
  end
end
