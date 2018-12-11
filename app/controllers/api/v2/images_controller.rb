module Api
  module V2
    class ImagesController < V2::BaseController
      include Foreman::Controller::Parameters::Image

      before_action :find_required_nested_object
      before_action :find_resource, :only => %w{show update destroy}

      api :GET, "/compute_resources/:compute_resource_id/images/", N_("List all images for a compute resource")
      api :GET, "/operatingsystems/:operatingsystem_id/images/", N_("List all images for operating system")
      api :GET, "/architectures/:architecture_id/images/", N_("List all images for architecture")
      param :compute_resource_id, String, :desc => N_("ID of compute resource")
      param :architecture_id, String, :desc => N_("ID of architecture")
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Image)

      def index
        @images = resource_scope_for_index
      end

      api :GET, "/compute_resources/:compute_resource_id/images/:id/", N_("Show an image")
      api :GET, "/operatingsystems/:operatingsystem_id/images/:id/", N_("Show an image")
      api :GET, "/architectures/:architecture_id/images/:id/", N_("Show an image")
      param :id, :identifier, :required => true
      param :compute_resource_id, String, :desc => N_("ID of compute resource")
      param :architecture_id, String, :desc => N_("ID of architecture")
      param :operatingsystem_id, String, :desc => N_("ID of operating system")

      def show
      end

      def_param_group :image do
        param :image, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :username, String, :required => true
          param :uuid, String, :required => true, :desc => N_("Template ID in the compute resource")
          param :password, String, :required => false
          param :compute_resource_id, String, :desc => N_("ID of compute resource")
          param :architecture_id, String, :desc => N_("ID of architecture")
          param :operatingsystem_id, String, :desc => N_("ID of operating system")
          param :user_data, :bool, :desc => N_("Whether or not the image supports user data"), :allow_nil => true
        end
      end

      api :POST, "/compute_resources/:compute_resource_id/images/", N_("Create an image")
      param :compute_resource_id, :identifier, :required => true
      param_group :image, :as => :create

      def create
        @image = nested_obj.images.new(image_params)
        process_response @image.save, nested_obj
      end

      api :PUT, "/compute_resources/:compute_resource_id/images/:id/", N_("Update an image")
      param :compute_resource_id, :identifier, :required => true
      param :id, :identifier, :required => true
      param_group :image

      def update
        process_response @image.update(image_params)
      end

      api :DELETE, "/compute_resources/:compute_resource_id/images/:id/", N_("Delete an image")
      param :compute_resource_id, :identifier, :required => true
      param :id, :identifier, :required => true

      def destroy
        process_response @image.destroy
      end

      private

      def allowed_nested_id
        %w(compute_resource_id operatingsystem_id architecture_id)
      end
    end
  end
end
