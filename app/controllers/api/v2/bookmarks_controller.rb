module Api
  module V2
    class BookmarksController < V2::BaseController
      include Foreman::Controller::BookmarkCommon
      include Foreman::Controller::Parameters::Bookmark

      before_action :find_resource, :only => [:show, :update, :destroy]

      api :GET, "/bookmarks/", N_("List all bookmarks")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Bookmark)

      def index
        @bookmarks = resource_scope_for_index
      end

      api :GET, "/bookmarks/:id/", N_("Show a bookmark")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :bookmark do
        param :bookmark, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :controller, String, :required => true
          param :query, String, :required => true
          param :public, :bool
        end
      end

      api :POST, "/bookmarks/", N_("Create a bookmark")
      param_group :bookmark, :as => :create

      def create
        @bookmark = Bookmark.new(bookmark_params)
        process_response @bookmark.save
      end

      api :PUT, "/bookmarks/:id/", N_("Update a bookmark")
      param :id, :identifier, :required => true
      param_group :bookmark

      def update
        process_response @bookmark.update(bookmark_params)
      end

      api :DELETE, "/bookmarks/:id/", N_("Delete a bookmark")
      param :id, :identifier, :required => true

      def destroy
        process_response @bookmark.destroy
      end
    end
  end
end
