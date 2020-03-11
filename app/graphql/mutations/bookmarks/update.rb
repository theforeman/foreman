module Mutations
  module Bookmarks
    class Update < UpdateMutation
      graphql_name 'UpdateBookmarkMutation'
      description 'Updates a bookmark'

      include Common
    end
  end
end
