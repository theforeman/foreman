module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      user_id = request.session['user']
      # Use unscoped to bypass Foreman's organization/location default scopes
      # since the tenant context isn't established during WebSocket handshake
      found_user = User.unscoped.find_by(id: user_id) if user_id
      found_user || reject_unauthorized_connection
    end
  end
end
