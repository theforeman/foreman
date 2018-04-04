class BookmarksController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::BookmarkCommon
  include Foreman::Controller::Parameters::Bookmark

  before_action :find_resource, :only => [:edit, :update, :destroy]

  def index
    @bookmarks = resource_base_search_and_page
  end

  def edit
  end

  def update
    if @bookmark.update(bookmark_params)
      redirect_to(bookmarks_path, :success => _('Bookmark was successfully updated'))
    else
      render :action => "edit"
    end
  end

  def destroy
    @bookmark.destroy
    redirect_to(bookmarks_url)
  end
end
