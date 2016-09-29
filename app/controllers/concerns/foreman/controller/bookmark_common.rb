module Foreman::Controller::BookmarkCommon
  def resource_base
    super.my_bookmarks
  end

  def resource_scope(*args)
    super.my_bookmarks
  end
end
