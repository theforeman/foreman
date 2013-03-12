object @puppetclass

attributes :id, :name

child :lookup_keys do
  attributes :id, :key, :default_value, :path, :default_value
end
