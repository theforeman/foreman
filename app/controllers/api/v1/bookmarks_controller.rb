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
        @bookmark = Bookmark.new(params[:bookmark])
        process_response @bookmark.save
      end

      def update
        process_response @bookmark.update_attributes(params[:bookmark])
      end

      def destroy
        process_response @bookmark.destroy
      end

    end
  end
end

