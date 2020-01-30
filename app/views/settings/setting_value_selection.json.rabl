object @select_values

attribute :kind

node(:collection, :if => lambda { |sel| sel.kind == :hash }) do |s|
  s.collection
end

node(:collection, :if => lambda { |sel| sel.kind == :array }) do |s|
  partial "settings/select_values", :object => s.collection
end
