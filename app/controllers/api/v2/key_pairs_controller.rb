module Api
  module V2
    class KeyPairsController <  V2::BaseController
      include Api::Version2

      before_action :find_compute_resource, :except => [:show]
      before_action :find_resource, :only => [:show]

      api :GET, '/compute_resources/:compute_resource_id/key_pairs', N_("List all SSH key for compute resource")
      param :compute_resource_id, String, :required => true, :desc => N_("ID or name of compute resource")

      def index
        @key_pairs = @compute_resource.get_compute_key_pairs
      end

      api :GET, '/compute_resources/:compute_resource_id/key_pairs/:id', N_("Show SSH key pair of a compute resource")
      param :compute_resource_id, String, :required => true, :desc => N_("ID or name of compute resource")
      param :id, String, :required => true, :desc => N_("ID of SSH key pair")

      def show
        @key_pair.update_attributes(audit_comment: _("%{user} Accessed %{key} secret via API") % {user: User.current.name, key: @key_pair.name})
      end

      api :POST, '/compute_resources/:compute_resource_id/key_pairs', N_('Create a new SSH key pair for compute resource')
      param :compute_resource_id, String, :required => true, :desc => N_("ID or name of compute resource")

      def create
        process_response @compute_resource.recreate
      end

      api :DELETE, '/compute_resources/:compute_resource_id/key_pairs/:id', N_("Show SSH key pair of a compute resource")
      param :compute_resource_id, String, :required => true, :desc => N_("ID or name of compute resource")
      param :id, String, :required => true, :desc => N_("ID of SSH key pair")

      def destroy
        key_to_delete = params[:id]
        return not_found unless key_to_delete
        process_response @compute_resource.delete_key_pair(key_to_delete)
      end

      private

      def find_compute_resource
        @compute_resource = ComputeResource.find(params[:compute_resource_id])
        return not_found unless @compute_resource.capabilities.include?(:key_pair)
        @compute_resource
      end

      def find_resource
        @key_pair = KeyPair.find(params[:id])
      end

      def get_resource
        @compute_resource
      end

      def action_permission
        case params[:action]
          when 'create'
            :destroy
          else
            super
        end
      end
    end
  end
end
