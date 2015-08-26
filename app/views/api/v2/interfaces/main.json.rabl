object @interface

extends "api/v2/interfaces/base"

attributes :subnet_id, :subnet_name, :domain_id, :domain_name, :created_at, :updated_at,
           :managed, :identifier, :compute_attributes

node do |interface|
  partial("api/v2/interfaces/types/#{interface.type_name.downcase}.json", :object => interface)
end
