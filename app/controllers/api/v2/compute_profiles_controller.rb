module Api
  module V2
    class ComputeProfilesController < V2::BaseController
      include Foreman::Controller::Parameters::ComputeProfile

      before_action :find_resource, :only => [:show, :update, :destroy]

      api :GET, "/compute_profiles", N_("List of compute profiles")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(ComputeProfile)

      def index
        @compute_profiles = resource_scope_for_index
      end

      api :GET, "/compute_profiles/:id/", N_("Show a compute profile")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :compute_profile do
        param :compute_profile, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
        end
      end

      api :POST, "/compute_profiles/", N_("Create a compute profile")
      param_group :compute_profile, :as => :create

      def create
        @compute_profile = ComputeProfile.new(compute_profile_params)
        process_response @compute_profile.save
      end

      api :PUT, "/compute_profiles/:id/", N_("Update a compute profile")
      param :id, String, :required => true
      param_group :compute_profile

      def update
        process_response @compute_profile.update(compute_profile_params)
      end

      api :DELETE, "/compute_profiles/:id/", N_("Delete a compute profile")
      param :id, String, :required => true

      def destroy
        process_response @compute_profile.destroy
      end
    end
  end
end
