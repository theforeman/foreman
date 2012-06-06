module Api
  module V1
    class BookmarksController < BaseController
      before_filter :find_by_name, :only => [:show, :update, :destroy]

      def index
        @bookmarks = Bookmark.paginate(:page => params[:page])
      end

      def show
      end

      def create
        respond_with Bookmark.create(params[:bookmark])
      end

      def update
        respond_with @bookmark.update_attributes(params[:bookmark])
      end

      def destroy
        respond_with @bookmark.destroy
      end

    end
  end
end

