object @compute_resource

extends "api/v2/compute_resources/base"

attributes :description, :url, :created_at, :updated_at

node do |r|
  partial("api/v2/compute_resources/#{r.provider.downcase}.json", :object => r)
end
