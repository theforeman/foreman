module Api
  module V2
    class SystemClassesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_system_id, :only => [:index, :create, :destroy]

      api :GET, "/systems/:system_id/puppetclass_ids/", "List all puppetclass id's for system"

      def index
        render :json => SystemClass.where(:system_id => system_id).pluck('puppetclass_id')
      end

      api :POST, "/systems/:system_id/puppetclass_ids", "Add a puppetclass to system"
      param :system_id, String, :required => true, :desc => "id of system"
      param :puppetclass_id, String, :required => true, :desc => "id of puppetclass"

      def create
        @system_class = SystemClass.create!(:system_id => system_id, :puppetclass_id => params[:puppetclass_id].to_i)
        render :json => {:system_id => @system_class.system_id, :puppetclass_id => @system_class.puppetclass_id}
      end

      api :DELETE, "/systems/:system_id/puppetclass_ids/:id/", "Remove a puppetclass from system"
      param :system_id, String, :required => true, :desc => "id of system"
      param :id, String, :required => true, :desc => "id of puppetclass"

      def destroy
        @system_class = SystemClass.where(:system_id => system_id, :puppetclass_id => params[:id])
        process_response @system_class.destroy_all
      end

      private
      attr_reader :system_id

      def find_system_id
        if params[:system_id] =~ /^\d+$/
          return @system_id = params[:system_id].to_i
        else
          @system ||= System::Managed.find_by_name(params[:system_id])
          return @system_id = @system.id if @system
          render_error 'not_found', :status => :not_found and return false
        end
      end

    end
  end
end