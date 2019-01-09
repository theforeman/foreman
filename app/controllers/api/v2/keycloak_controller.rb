module Api
  module V2
    class KeycloakController < ActionController::Base
      def authentication
        require 'pry'; binding.pry;
      end
    end
  end
end