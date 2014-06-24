module Api
  module V2
    class ComputeAttributesController < V2::BaseController

      before_filter :find_resource, :only => :update

      def_param_group :compute_attribute do
        param :compute_attribute, Hash, :action_aware => true do
          param :vm_attrs, Hash, :required => true
        end
      end

      api :POST, "/compute_resources/:compute_resource_id/compute_profiles/:compute_profile_id/compute_attributes", "Create a compute attribute"
      api :POST, "/compute_profiles/:compute_profile_id/compute_resources/:compute_resource_id/compute_attributes", "Create a compute attribute"
      api :POST, "/compute_resources/:compute_resource_id/compute_attributes", "Create a compute attribute"
      api :POST, "/compute_profiles/:compute_profile_id/compute_attributes", "Create a compute attribute"
      api :POST, "/compute_attributes/", "Create a compute attribute."
      param :compute_profile_id, :identifier, :required => true
      param :compute_resource_id, :identifier, :required => true
      param_group :compute_attribute, :as => :create

      def create
        params[:compute_attribute].merge!(:compute_profile_id => params[:compute_profile_id],
                                          :compute_resource_id => params[:compute_resource_id])
        @compute_attribute = ComputeAttribute.create!(params[:compute_attribute])
        render :json => @compute_attribute.to_json
      end

      api :PUT, "/compute_resources/:compute_resource_id/compute_profiles/:compute_profile_id/compute_attributes/:id", "Update a compute attribute"
      api :PUT, "/compute_profiles/:compute_profile_id/compute_resources/:compute_resource_id/compute_attributes/:id", "Update a compute attribute"
      api :PUT, "/compute_resources/:compute_resource_id/compute_attributes/:id", "Update a compute attribute"
      api :PUT, "/compute_profiles/:compute_profile_id/compute_attributes/:id", "Update a compute attribute"
      api :PUT, "/compute_attributes/:id", "Update a compute attribute."

      param :compute_profile_id, :identifier, :required => false
      param :compute_resource_id, :identifier, :required => false
      param :id, String, :required => true
      param_group :compute_attribute

      def update
        process_response @compute_attribute.update_attributes(params[:compute_attribute])
      end

    end
  end
end
