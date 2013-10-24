object @compute_resource

attributes :id, :name, :description, :url, :created_at, :updated_at
attribute :provider_friendly_name => 'provider'

node do |r|
  partial("api/v1/compute_resources/#{r.provider.downcase}.json", :object => r)
end
