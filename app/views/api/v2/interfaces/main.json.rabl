object @interface

extends "api/v2/interfaces/base"

attributes :subnet_id, :subnet_name, :subnet6_id, :subnet6_name, :domain_id, :domain_name, :created_at, :updated_at,
  :managed, :identifier

node do |interface|
  unless interface.type.nil?
    partial("api/v2/interfaces/types/#{interface.type_name.downcase}.json", :object => interface)
  end
end
