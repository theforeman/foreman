module Api
  module V2
    class ComputeAttributesController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::ComputeAttribute

      before_action :find_optional_nested_object
      before_action :find_resource, :only => [:show, :update]

      def_param_group :compute_attribute do
        param :compute_attribute, Hash, :required => true, :action_aware => true do
          param :vm_attrs, Hash, :required => true
        end
      end

      api :GET, "/compute_resources/:compute_resource_id/compute_profiles/:compute_profile_id/compute_attributes/", N_("List of compute attributes for provided compute profile and compute resource")
      api :GET, "/compute_profiles/:compute_profile_id/compute_resources/:compute_resource_id/compute_attributes/", N_("List of compute attributes for provided compute profile and compute resource")
      api :GET, "/compute_resources/:compute_resource_id/compute_attributes/", N_("List of compute attributes for compute resource")
      api :GET, "/compute_profiles/:compute_profile_id/compute_attributes/", N_("List of compute attributes for compute profile")
      api :GET, "/compute_attributes/:id", N_("List of compute attributes")
      param :compute_profile_id, String, :desc => N_("ID of compute profile")
      param :compute_resource_id, String, :desc => N_("ID of compute_resource")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(ComputeAttribute)

      def index
        @compute_attributes = resource_scope_for_index
      end

      api :GET, "/compute_resources/:compute_resource_id/compute_profiles/:compute_profile_id/compute_attributes/:id", N_("Show a compute attributes set")
      api :GET, "/compute_profiles/:compute_profile_id/compute_resources/:compute_resource_id/compute_attributes/:id", N_("Show a compute attributes set")
      api :GET, "/compute_resources/:compute_resource_id/compute_attributes/:id", N_("Show a compute attributes set")
      api :GET, "/compute_profiles/:compute_profile_id/compute_attributes/:id", N_("Show a compute attributes set")
      api :GET, "/compute_attributes/:id", N_("Show a compute attributes set")

      def show
      end

      api :POST, "/compute_resources/:compute_resource_id/compute_profiles/:compute_profile_id/compute_attributes", N_("Create a compute attributes set")
      api :POST, "/compute_profiles/:compute_profile_id/compute_resources/:compute_resource_id/compute_attributes", N_("Create a compute attributes set")
      api :POST, "/compute_resources/:compute_resource_id/compute_attributes", N_("Create a compute attributes set")
      api :POST, "/compute_profiles/:compute_profile_id/compute_attributes", N_("Create a compute attributes set")
      api :POST, "/compute_attributes/", N_("Create a compute attributes set")
      param :compute_profile_id, :identifier, :required => true
      param :compute_resource_id, :identifier, :required => true
      param_group :compute_attribute, :as => :create

      def create
        @compute_attribute = ComputeAttribute.new(compute_attribute_params.merge(
          :compute_profile_id => params[:compute_profile_id],
          :compute_resource_id => params[:compute_resource_id]))
        process_response @compute_attribute.save if @compute_attribute.normalized_vm_attrs
      end

      api :PUT, "/compute_resources/:compute_resource_id/compute_profiles/:compute_profile_id/compute_attributes/:id", N_("Update a compute attributes set")
      api :PUT, "/compute_profiles/:compute_profile_id/compute_resources/:compute_resource_id/compute_attributes/:id", N_("Update a compute attributes set")
      api :PUT, "/compute_resources/:compute_resource_id/compute_attributes/:id", N_("Update a compute attributes set")
      api :PUT, "/compute_profiles/:compute_profile_id/compute_attributes/:id", N_("Update a compute attributes set")
      api :PUT, "/compute_attributes/:id", N_("Update a compute attributes set")

      param :compute_profile_id, :identifier, :required => false
      param :compute_resource_id, :identifier, :required => false
      param :id, String, :required => true
      param_group :compute_attribute

      def update
        process_response @compute_attribute.update(compute_attribute_params) if @compute_attribute.normalized_new_vm_attrs(compute_attribute_params[:vm_attrs])
      end

      private

      def allowed_nested_id
        %w(compute_resource_id compute_profile_id)
      end
    end
  end
end
