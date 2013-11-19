module Api
  module V2
    class SystemGroupClassesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_system_group_id, :only => [:index, :create, :destroy]

      api :GET, "/system_groups/:system_group_id/puppetclass_ids/", "List all puppetclass id's for system_group"

      def index
        render :json => SystemGroupClass.where(:system_group_id => system_group_id).pluck('puppetclass_id')
      end

      api :POST, "/system_groups/:system_group_id/puppetclass_ids", "Add a puppetclass to system_group"
      param :system_group_id, String, :required => true, :desc => "id of system_group"
      param :puppetclass_id, String, :required => true, :desc => "id of puppetclass"

      def create
        @system_group_class = SystemGroupClass.create!(:system_group_id => system_group_id, :puppetclass_id => params[:puppetclass_id].to_i)
        render :json => {:system_group_id => @system_group_class.system_group_id, :puppetclass_id => @system_group_class.puppetclass_id}
      end

      api :DELETE, "/system_groups/:system_group_id/puppetclass_ids/:id/", "Remove a puppetclass from system_group"
      param :system_group_id, String, :required => true, :desc => "id of system_group"
      param :puppetclass_id, String, :required => true, :desc => "id of puppetclass"

      def destroy
        @system_group_class = SystemGroupClass.where(:system_group_id => @system_group_id, :puppetclass_id => params[:id])
        process_response @system_group_class.destroy_all
      end

      private
      attr_reader :system_group_id

      # params[:system_group_id] is "id-to_label.parameterize" and .to_i returns the id
      def find_system_group_id
        @system_group_id = params[:system_group_id].to_i
      end

    end
  end
end