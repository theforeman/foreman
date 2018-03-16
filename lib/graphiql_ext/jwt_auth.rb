module GraphiqlExt
  module JwtAuth
    extend ActiveSupport::Concern

    included do
      before_action :set_auth_headers, only: :show

      private

      def set_auth_headers
        user_id = params[:user_id]

        if user_id.present? && (user = User.unscoped.find(user_id))
          GraphiQL::Rails.config.headers['Authorization'] = ->(_context) { user.jwt_token! }
        elsif GraphiQL::Rails.config.headers.key? 'Authorization'
          # Reset Authorization if previously set
          GraphiQL::Rails.config.headers.delete 'Authorization'
        end
      end
    end
  end
end
