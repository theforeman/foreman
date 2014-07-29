module Api
  module V2
    class BookmarksController < V2::BaseController
      before_filter :find_resource, :only => [:show, :update, :destroy]

      api :GET, "/bookmarks/", N_("List all bookmarks")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @bookmarks = Bookmark.paginate(paginate_options)
      end

      api :GET, "/bookmarks/:id/", N_("Show a bookmark")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :bookmark do
        param :bookmark, Hash, :action_aware => true do
          param :name, String, :required => true
          param :controller, String, :required => true
          param :query, String, :required => true
          param :public, :bool
        end
      end

      api :POST, "/bookmarks/", N_("Create a bookmark")
      param_group :bookmark, :as => :create

      def create
        @bookmark = Bookmark.new(params[:bookmark])
        process_response @bookmark.save
      end

      api :PUT, "/bookmarks/:id/", N_("Update a bookmark")
      param :id, :identifier, :required => true
      param_group :bookmark

      def update
        process_response @bookmark.update_attributes(params[:bookmark])
      end

      api :DELETE, "/bookmarks/:id/", N_("Delete a bookmark")
      param :id, :identifier, :required => true

      def destroy
        process_response @bookmark.destroy
      end

    end
  end
end




