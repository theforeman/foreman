class BookmarksController < ApplicationController
  before_filter :find_resource, :only => [:edit, :update, :destroy]

  def index
    @bookmarks = resource_base.paginate(:page => params[:page])
  end

  def new
    @bookmark            = Bookmark.new
    @bookmark.name       = params[:query].to_s.strip.split(/\s| = |!|~|>|</)[0]
    @bookmark.controller = params[:kontroller]
  end

  def edit
  end

  def create
    @bookmark = Bookmark.new(foreman_params)
    if @bookmark.save
      redirect_to send("#{@bookmark.controller}_path"), :notice => _('Bookmark was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    if @bookmark.update_attributes(foreman_params)
      redirect_to(bookmarks_path, :notice => _('Bookmark was successfully updated.'))
    else
      render :action => "edit"
    end
  end

  def destroy
    @bookmark.destroy
    redirect_to(bookmarks_url)
  end
end
