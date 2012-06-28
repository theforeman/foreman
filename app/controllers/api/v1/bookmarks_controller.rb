module Api
  module V1
    class BookmarksController < BaseController
      before_filter :find_resource, :only => [:show, :update, :destroy]

      api :GET, "/bookmarks/", "List all bookmarks."
      def index
        @bookmarks = Bookmark.all
      end

      api :GET, "/bookmarks/:id/", "Show a bookmark."
      def show
      end

      api :POST, "/bookmarks/", "Create a bookmark."
      param :bookmark, Hash, :required => true do
        param :name, String, :required => true
        param :controller, String, :required => true
        param :query, String, :required => true
      end
      def create
        @bookmark = Bookmark.new(params[:bookmark])
        process_response @bookmark.save
      end

      api :PUT, "/bookmarks/:id/", "Update a bookmark."
      param :bookmark, Hash, :required => true do
        param :name, String
        param :controller, String
        param :query, String
      end
      def update
        process_response @bookmark.update_attributes(params[:bookmark])
      end

      api :DELETE, "/bookmarks/:id/", "Delete a bookmark."
      def destroy
        process_response @bookmark.destroy
      end

    end
  end
end




