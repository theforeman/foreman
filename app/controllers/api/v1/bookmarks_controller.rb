module Api
  module V1
    class BookmarksController < V1::BaseController
      before_filter :find_resource, :only => [:show, :update, :destroy]

      api :GET, "/bookmarks/", "List all bookmarks."
      param :page,  String, :desc => "paginate results"
      def index
        @bookmarks = Bookmark.paginate(:page => params[:page])
      end

      api :GET, "/bookmarks/:id/", "Show a bookmark."
      param :id, :identifier, :required => true
      def show
      end

      api :POST, "/bookmarks/", "Create a bookmark."
      param :bookmark, Hash, :required => true do
        param :name, String, :required => true
        param :controller, String, :required => true
        param :query, String, :required => true
        param :public, :bool
      end
      def create
        @bookmark = Bookmark.new(params[:bookmark])
        process_response @bookmark.save
      end

      api :PUT, "/bookmarks/:id/", "Update a bookmark."
      param :id, :identifier, :required => true
      param :bookmark, Hash, :required => true do
        param :name, String, :required => true
        param :controller, String, :required => true
        param :query, String, :required => true
        param :public, :bool
      end
      def update
        process_response @bookmark.update_attributes(params[:bookmark])
      end

      api :DELETE, "/bookmarks/:id/", "Delete a bookmark."
      param :id, :identifier, :required => true
      def destroy
        process_response @bookmark.destroy
      end

    end
  end
end




