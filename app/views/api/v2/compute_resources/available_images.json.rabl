collection @available_images, :object_root => :image

node :uuid do |img|
  img.id
end
attribute :name
