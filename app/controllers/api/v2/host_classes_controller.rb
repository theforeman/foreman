module Api
  module V2
    class HostClassesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_host_id, :only => [:index, :create, :destroy]

      api :GET, "/hosts/:host_id/puppetclass_ids/", "List all puppetclass id's for host"

      def index
        render :json => HostClass.where(:host_id => host_id).pluck('puppetclass_id')
      end

      api :POST, "/hosts/:host_id/puppetclass_ids", "Add a puppetclass to host"
      param :host_id, String, :required => true, :desc => "id of host"
      param :puppetclass_id, String, :required => true, :desc => "id of puppetclass"

      def create
        @host_class = HostClass.create!(:host_id => host_id, :puppetclass_id => params[:puppetclass_id].to_i)
        render :json => {:host_id => @host_class.host_id, :puppetclass_id => @host_class.puppetclass_id}
      end

      api :DELETE, "/hosts/:host_id/puppetclass_ids/:id/", "Remove a puppetclass from host"
      param :host_id, String, :required => true, :desc => "id of host"
      param :id, String, :required => true, :desc => "id of puppetclass"

      def destroy
        @host_class = HostClass.where(:host_id => host_id, :puppetclass_id => params[:id])
        process_response @host_class.destroy_all
      end

      private
      attr_reader :host_id

      def find_host_id
        if params[:host_id] =~ /^\d+$/
          return @host_id = params[:host_id].to_i
        else
          @host ||= Host::Managed.find_by_name(params[:host_id])
          return @host_id = @host.id if @host
          render_error 'not_found', :status => :not_found and return false
        end
      end

    end
  end
end