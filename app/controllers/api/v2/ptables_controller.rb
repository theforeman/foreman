module Api
  module V2
    class PtablesController < V2::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/ptables/", N_("List all partition tables")
      param :search, String, :desc => N_("filter results")
      param :order, String, :desc => N_("sort results")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @ptables = Ptable.
          authorized(:view_ptables).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/ptables/:id/", N_("Show a partition table")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :ptable do
        param :ptable, Hash, :action_aware => true do
          param :name, String, :required => true
          param :layout, String, :required => true
          param :os_family, String, :required => false
        end
      end

      api :POST, "/ptables/", N_("Create a partition table")
      param_group :ptable, :as => :create

      def create
        @ptable = Ptable.new(params[:ptable])
        process_response @ptable.save
      end

      api :PUT, "/ptables/:id/", N_("Update a partition table")
      param :id, String, :required => true
      param_group :ptable

      def update
        process_response @ptable.update_attributes(params[:ptable])
      end

      api :DELETE, "/ptables/:id/", N_("Delete a partition table")
      param :id, String, :required => true

      def destroy
        process_response @ptable.destroy
      end

    end
  end
end
