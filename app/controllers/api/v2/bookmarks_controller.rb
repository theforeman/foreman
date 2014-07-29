module Api
  module V2
    class BookmarksController < V2::BaseController

      wrap_parameters :bookmark, :include => (Bookmark.attribute_names + ['controller_name']), :format => :json

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

      def_param_group :bookmark do
        param :name, String, :required => true, :action_aware => true
        param :controller_name, String, :required => true, :action_aware => true
        param :query, String, :required => true, :action_aware => true
        param :public, :bool
      end

      api :POST, "/bookmarks/", "Create a bookmark."
      param_group :bookmark, :as => :create

      def create
        @bookmark = Bookmark.new(params[:bookmark])
        process_response @bookmark.save
      end

      api :PUT, "/bookmarks/:id/", "Update a bookmark."
      param :id, :identifier, :required => true
      param_group :bookmark

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




