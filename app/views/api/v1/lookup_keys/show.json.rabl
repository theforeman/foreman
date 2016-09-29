object @lookup_key => :lookup_key

attributes :key, :required, :override, :description, :default_value, :id

node(:is_param) { |key| key.puppet? }
