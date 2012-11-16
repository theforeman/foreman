object @bookmark
attributes :name, :controller, :query, :public, :id
child :owner do
  attributes :name
  attributes :login
  attributes :mail, :as => :email
end

