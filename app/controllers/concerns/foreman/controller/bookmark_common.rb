module Foreman::Controller::BookmarkCommon
  def resource_base
    Bookmark.my_bookmarks
  end

  def resource_scope(*args)
    Bookmark.my_bookmarks
  end
end
