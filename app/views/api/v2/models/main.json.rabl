object @model

extends "api/v2/models/base"

attributes :info, :created_at, :updated_at, :vendor_class, :hardware_model

node(:hosts_count) { |model| @hosts_count[model] } unless @hosts_count.nil?
