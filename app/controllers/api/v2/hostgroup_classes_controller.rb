module Api
  module V2
    class HostgroupClassesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_hostgroup_id, :only => [:index, :create, :destroy]

      api :GET, "/hostgroups/:hostgroup_id/puppetclass_ids/", "List all puppetclass id's for hostgroup"

      def index
        render :json => HostgroupClass.where(:hostgroup_id => hostgroup_id).pluck('puppetclass_id')
      end

      api :POST, "/hostgroups/:hostgroup_id/puppetclass_ids", "Add a puppetclass to hostgroup"
      param :hostgroup_id, String, :required => true, :desc => "id of hostgroup"
      param :puppetclass_id, String, :required => true, :desc => "id of puppetclass"

      def create
        @hostgroup_class = HostgroupClass.create!(:hostgroup_id => hostgroup_id, :puppetclass_id => params[:puppetclass_id].to_i)
        render :json => {:hostgroup_id => @hostgroup_class.hostgroup_id, :puppetclass_id => @hostgroup_class.puppetclass_id}
      end

      api :DELETE, "/hostgroups/:hostgroup_id/puppetclass_ids/:id/", "Remove a puppetclass from hostgroup"
      param :hostgroup_id, String, :required => true, :desc => "id of hostgroup"
      param :puppetclass_id, String, :required => true, :desc => "id of puppetclass"

      def destroy
        @hostgroup_class = HostgroupClass.where(:hostgroup_id => @hostgroup_id, :puppetclass_id => params[:id])
        process_response @hostgroup_class.destroy_all
      end

      private
      attr_reader :hostgroup_id

      # params[:hostgroup_id] is "id-to_label.parameterize" and .to_i returns the id
      def find_hostgroup_id
        @hostgroup_id = params[:hostgroup_id].to_i
      end

    end
  end
end