object @lookup_key => :lookup_key

node :default_value do |lkey|
  lkey.default.value
end

attributes :key, :required, :override, :description, :id

node(:is_param) { |key| key.puppet? }
