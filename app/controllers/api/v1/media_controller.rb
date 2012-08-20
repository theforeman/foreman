module Api
  module V1
    class MediaController < BaseController
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

#{Operatingsystem.families.map{|f| "* " + f}.join("\n")}
eos

      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      api :GET, "/media/", "List all media."
      def index
        @media = Medium.search_for(params[:search], :order => params[:order])
      end

      api :GET, "/media/:id/", "Show a medium."
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

      param :medium, Hash, :required => true do
        param :name, String, :required => false, :desc => "Name of media"
        param :path, String, :required => false, :desc => PATH_INFO
        param :os_family, String, :require => false, :desc => OS_FAMILY_INFO
      end
      api :PUT, "/media/:id/", "Update a medium."
      def update
        process_response @medium.update_attributes(params[:medium])
      end

      api :DELETE, "/media/:id/", "Delete a medium."
      def destroy
        process_response @medium.destroy
      end

    end
  end
end
