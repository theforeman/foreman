object @smart_proxy

attributes :name, :id, :url, :created_at, :updated_at

child :features do
	attributes :name, :id, :url
end


