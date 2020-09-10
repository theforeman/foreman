module Api
  module V2
    class MediaController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::Medium

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy}

      PATH_INFO = <<~EOS
        The path to the medium, can be a URL or a valid NFS server (exclusive of the architecture).

        for example http://mirror.centos.org/centos/$version/os/$arch
        where $arch will be substituted for the host\'s actual OS architecture and $version, $major and $minor
        will be substituted for the version of the operating system.

        Solaris and Debian media may also use $release.
      EOS

      # values for FAMILIES are defined in apipie initializer
      OS_FAMILY_INFO = N_("Operating system family, available values: %{operatingsystem_families}")

      api :GET, "/media/", N_("List all installation media")
      api :GET, "/operatingsystems/:operatingsystem_id/media", N_("List all media for an operating system")
      api :GET, "/locations/:location_id/media", N_("List all media per location")
      api :GET, "/organizations/:organization_id/media", N_("List all media per organization")
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Medium)

      def index
        @media = resource_scope_for_index
      end

      api :GET, "/media/:id/", N_("Show a medium")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :medium do
        param :medium, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("Name of media")
          param :path, String, :required => true, :desc => PATH_INFO
          param :os_family, String, :require => false, :desc => OS_FAMILY_INFO
          param :operatingsystem_ids, Array, :require => false
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/media/", N_("Create a medium")
      param_group :medium, :as => :create

      def create
        @medium = Medium.new(medium_params)
        process_response @medium.save
      end

      api :PUT, "/media/:id/", N_("Update a medium")
      param :id, String, :required => true
      param_group :medium

      def update
        process_response @medium.update(medium_params)
      end

      param :id, :identifier, :required => true
      api :DELETE, "/media/:id/", N_("Delete a medium")

      def destroy
        process_response @medium.destroy
      end

      private

      def allowed_nested_id
        %w(operatingsystem_id location_id organization_id)
      end
    end
  end
end
