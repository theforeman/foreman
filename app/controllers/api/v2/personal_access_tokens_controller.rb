module Api
  module V2
    class PersonalAccessTokensController < V2::BaseController
      include Foreman::Controller::Parameters::PersonalAccessToken
      include Foreman::Controller::UserAware

      before_action :find_resource, :only => %w{show destroy purge}

      api :GET, "/users/:user_id/personal_access_tokens", N_("List all Personal Access Tokens for a user")
      param :user_id, String, :desc => N_("ID of the user"), :required => true
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(PersonalAccessToken)

      def index
        @personal_access_tokens = resource_scope_for_index
      end

      api :GET, "/users/:user_id/personal_access_tokens/:id/", N_("Show a Personal Access Token for a user")
      param :id, :identifier, :required => true
      param :user_id, String, :desc => N_("ID of the user"), :required => true

      def show
      end

      def_param_group :personal_access_token do
        param :user_id, String, :desc => N_("ID of the user"), :required => true
        param :personal_access_token, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :expires_at, DateTime, :desc => N_("Expiry Date")
        end
      end

      api :POST, "/users/:user_id/personal_access_tokens", N_("Create a Personal Access Token for a user")
      param_group :personal_access_token, :as => :create

      def create
        @personal_access_token = PersonalAccessToken.new(personal_access_token_params.merge(:user => @user))
        @token_value = @personal_access_token.generate_token
        process_response @personal_access_token.save
      end

      api :DELETE, "/users/:user_id/personal_access_tokens/:id/", N_("Revoke a Personal Access Token for a user")
      param :id, String, :required => true
      param :user_id, String, :desc => N_("ID of the user"), :required => true

      def destroy
        process_response @personal_access_token.revoke!
      end

      api :DELETE, "/users/:user_id/personal_access_tokens/:id/purge", N_("Permanently delete an inactive Personal Access Token for a user")
      param :id, String, :required => true
      param :user_id, String, :desc => N_("ID of the user"), :required => true

      def purge
        if @personal_access_token.active?
          render_error :custom_error, :status => :unprocessable_entity,
            :locals => { :message => _("Active Personal Access Tokens must be revoked before they can be deleted.") }
        else
          process_response @personal_access_token.destroy
        end
      end

      private

      def action_permission
        case params[:action]
        when 'destroy', 'purge'
          'revoke'
        else
          super
        end
      end

      def parent_permission(child_perm)
        case child_perm.to_s
        when 'revoke'
          'edit'
        else
          super
        end
      end

      def resource_scope(...)
        if editing_self?
          resource_class.where(user: @user).readonly(false)
        else
          super
        end
      end
    end
  end
end
