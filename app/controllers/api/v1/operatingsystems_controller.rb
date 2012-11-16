module Api
  module V1
    class OperatingsystemsController < V1::BaseController

      resource_description do
        name 'Operating systems'
      end

      before_filter :find_resource, :only => %w{show edit update destroy bootfiles}

      api :GET, "/operatingsystems/", "List all operating systems."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      def index
        @operatingsystems = Operatingsystem.search_for(params[:search], :order => params[:order])
      end

      api :GET, "/operatingsystems/:id/", "Show an OS."
      param :id, String, :required => true
      def show
      end

      api :POST, "/operatingsystems/", "Create an OS."
      param :operatingsystem, Hash, :required => true do
        param :name, /\A(\S+)\Z/, :required => true
        param :major, String, :required => true
        param :minor, String, :required => true
      end
      def create
        @operatingsystem = Operatingsystem.new(params[:operatingsystem])
        process_response @operatingsystem.save
      end

      api :PUT, "/operatingsystems/:id/", "Update an OS."
      param :id, String, :required => true
      param :operatingsystem, Hash, :required => true do
        param :name, /\A(\S+)\Z/
        param :major, String
        param :minor, String
      end
      def update
        process_response @operatingsystem.update_attributes(params[:operatingsystem])
      end

      api :DELETE, "/operatingsystems/:id/", "Delete a bookmark."
      param :id, String, :required => true
      def destroy
        process_response @operatingsystem.destroy
      end

      api :GET, "/operatingsystems/:id/bootfiles/", "List boot files an OS."
      param :id, String, :required => true
      param :medium, String
      param :architecture, String
      def bootfiles
        medium = Medium.find_by_name(params[:medium])
        arch   = Architecture.find_by_name(params[:architecture])
        render :json => @operatingsystem.pxe_files(medium, arch)
      rescue => e
        render :json => e.to_s, :status => :unprocessable_entity
      end

    end
  end
end
