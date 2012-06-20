module Api
  module V1
    class BookmarksController < BaseController
      before_filter :find_by_name, :only => [:show, :update, :destroy]

      def index
        @bookmarks = Bookmark.all
      end

      def show
      end

      def create
        @bookmark = Bookmark.create(params[:bookmark])
      end

      def update
        @bookmark.update_attributes(params[:bookmark])
      end

      def destroy
        respond_with @bookmark.destroy
      end

    end
  end
end

