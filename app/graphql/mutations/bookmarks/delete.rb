module Mutations
  module Bookmarks
    class Delete < DeleteMutation
      graphql_name 'DeleteBookmarkMutation'
      description 'Deletes a bookmark'
    end
  end
end
