Types::BookmarkType = GraphQL::ObjectType.define do
  name 'Bookmark'
  description 'A Bookmark'

  backed_by_model :bookmark do
    attr :id
    attr :name
    attr :controller
    attr :public
  end
end
