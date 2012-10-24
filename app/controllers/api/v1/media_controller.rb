module Api
  module V1
    class MediaController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      PATH_INFO = <<-eos
The path to the medium, can be a URL or a valid NFS server (exclusive of the architecture).

for example http://mirror.averse.net/centos/$version/os/$arch
where $arch will be substituted for the host\'s actual OS architecture and $version, $major and $minor
will be substituted for the version of the operating system.

Solaris and Debian media may also use $release.
      eos

      OS_FAMILY_INFO = <<-eos
The family that the operating system belongs to.

Available families:

#{Operatingsystem.families.map { |f| "* " + f }.join("\n")}
      eos

      api :GET, "/media/", "List all media."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @media = Medium.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/media/:id/", "Show a medium."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/medium/", "Create a medium."
      param :medium, Hash, :required => true do
        param :name, String, :required => true, :desc => "Name of media"
        param :path, String, :required => true, :desc => PATH_INFO
        param :os_family, String, :require => false, :desc => OS_FAMILY_INFO
      end

      def create
        @medium = Medium.new(params[:medium])
        process_response @medium.save
      end

      param :id, String, :required => true
      param :medium, Hash, :required => true do
        param :name, String, :required => false, :desc => "Name of media"
        param :path, String, :required => false, :desc => PATH_INFO
        param :os_family, String, :require => false, :allow_nil => true, :desc => OS_FAMILY_INFO
      end
      api :PUT, "/media/:id/", "Update a medium."

      def update
        process_response @medium.update_attributes(params[:medium])
      end

      param :id, :identifier, :required => true
      api :DELETE, "/media/:id/", "Delete a medium."

      def destroy
        process_response @medium.destroy
      end

    end
  end
end
