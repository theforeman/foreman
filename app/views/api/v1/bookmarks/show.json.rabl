object @bookmark
attributes :name, :controller, :query, :public, :id, :owner_id, :owner_type
child :owner do
  attributes :name
  attributes :login
  attributes :mail, :as => :email
end

