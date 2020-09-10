module Api
  module V2
    class SshKeysController < V2::BaseController
      include Foreman::Controller::Parameters::SshKey
      include Foreman::Controller::UserAware

      before_action :find_resource, :only => %w{show destroy}

      api :GET, "/users/:user_id/ssh_keys", N_("List all SSH keys for a user")
      param :user_id, String, :desc => N_("ID of the user"), :required => true
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(SshKey)

      def index
        @ssh_keys = resource_scope_for_index
      end

      api :GET, "/users/:user_id/ssh_keys/:id/", N_("Show an SSH key from a user")
      param :id, :identifier, :required => true
      param :user_id, String, :desc => N_("ID of the user"), :required => true

      def show
      end

      def_param_group :ssh_key do
        param :user_id, String, :desc => N_("ID of the user"), :required => true
        param :ssh_key, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :key, String, :required => true, :desc => N_("Public SSH key")
        end
      end

      api :POST, "/users/:user_id/ssh_keys", N_("Add an SSH key for a user")
      param_group :ssh_key, :as => :create

      def create
        @ssh_key = SshKey.new(ssh_key_params.merge(:user => @user))
        process_response @ssh_key.save
      end

      api :DELETE, "/users/:user_id/ssh_keys/:id/", N_("Delete an SSH key for a user")
      param :id, String, :required => true
      param :user_id, String, :desc => N_("ID of the user"), :required => true

      def destroy
        process_response @ssh_key.destroy
      end
    end
  end
end
