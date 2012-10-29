module Api
  module V1
    class HostgroupsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/hostgroups/", "List all hostgroups."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @hostgroups = Hostgroup.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
      end

      api :GET, "/hostgroups/:id/", "Show a hostgroup."
      param :id, :identifier, :required => true
      def show
      end

    end
  end
end
