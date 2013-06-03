class BookmarksController < ApplicationController
  before_filter :find_by_name, :only => %w{show edit update destroy}

  def index
    @bookmarks = Bookmark.paginate(:page => params[:page])

    respond_to do |format|
      format.html
      format.json { render :json => @bookmarks }
    end
  end

  def new
    @bookmark            = Bookmark.new
    @bookmark.name       = params[:query].to_s.strip.split(/\s| = |!|~|>|</)[0]
    @bookmark.controller = params[:kontroller]

    respond_to do |format|
      format.html
    end
  end

  def edit
  end

  def create
    @bookmark = Bookmark.new(params[:bookmark])

    respond_to do |format|
      if @bookmark.save
        format.html { redirect_to send("#{@bookmark.controller}_path"), :notice => _('Bookmark was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @bookmark.update_attributes(params[:bookmark])
        format.html { redirect_to(bookmarks_path, :notice => _('Bookmark was successfully updated.')) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @bookmark.destroy

    respond_to do |format|
      format.html { redirect_to(bookmarks_url) }
    end
  end
end
