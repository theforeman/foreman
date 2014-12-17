module Api
  module V1
    class BookmarksController < V1::BaseController
      before_filter :find_resource, :only => [:show, :update, :destroy]

      api :GET, "/bookmarks/", "List all bookmarks."
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @bookmarks = Bookmark.paginate(paginate_options)
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
        @bookmark = Bookmark.new(foreman_params)
        process_response @bookmark.save
      end

      api :PUT, "/bookmarks/:id/", "Update a bookmark."
      param :id, :identifier, :required => true
      param :bookmark, Hash, :required => true do
        param :name, String
        param :controller, String
        param :query, String
        param :public, :bool
      end

      def update
        process_response @bookmark.update_attributes(foreman_params)
      end

      api :DELETE, "/bookmarks/:id/", "Delete a bookmark."
      param :id, :identifier, :required => true

      def destroy
        process_response @bookmark.destroy
      end
    end
  end
end




