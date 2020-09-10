module Foreman
  module Controller
    module ApiCsrfProtection
      extend ActiveSupport::Concern

      included do
        protect_from_forgery if: :protect_api_from_forgery?
      end

      private

      def protect_api_from_forgery?
        session[:user].present? && !session[:api_authenticated_session]
      end
    end
  end
end
