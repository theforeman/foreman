module Api
  module V2
    class RegistrationTokensController < V2::BaseController
      include Foreman::Controller::UserSelfEditing

      before_action :authenticate, :only => [:invalidate_jwt_tokens, :invalidate_jwt]

      def resource_class
        User
      end

      def resource_name(resource = resource_class.model_name.name.downcase)
        resource
      end

      def find_resource(permission = :view_users)
        editing_self? ? User.find(User.current.id) : User.authorized(permission).except_hidden.find(params[:id])
      end

      def action_permission
        case params[:action]
        when 'invalidate_jwt_tokens', 'invalidate_jwt'
          'edit'
        else
          super
        end
      end

      api :DELETE, '/users/:user_id/registration_tokens', N_("Invalidate all registration tokens for a specific user")
      description <<-DOC
      The user you specify will no longer be able to register hosts by using their JWTs.
      DOC
      param :user_id, String, :desc => N_("ID of the user"), :required => true

      def invalidate_jwt
        @user = find_resource(:edit_users)
        @user.jwt_secret&.destroy
        login = @user.login
        render :json => { :message => _("Successfully invalidated registration tokens."), :user => login}, :status => :ok
      end

      api :DELETE, "/registration_tokens", N_("Invalidate all registration tokens for multiple users")
      param :search, String, :desc => N_("URL-encoded search query that selects users for which registration tokens will be invalidated. Search query example: id ^ (2, 4, 6)"), :required => true
      description <<-DOC
      The users you specify will no longer be able to register hosts by using their JWTs.
      DOC

      def invalidate_jwt_tokens
        raise ::Foreman::Exception.new(N_("Please provide search parameter")) if params[:search].blank?
        @users = resource_scope_for_index(:permission => :edit_users).except_hidden.uniq
        if @users.blank?
          raise ::Foreman::Exception.new(N_("No record found for search '%s'"), params[:search]) end
        JwtSecret.where(user_id: @users).destroy_all
        login = @users.pluck(:login).to_sentence
        render :json => { :message => _("Successfully invalidated registration tokens."), :users => login}, :status => :ok
      end
    end
  end
end
