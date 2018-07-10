object @model

extends "api/v2/models/base"
extends "api/v2/layouts/permissions"

attributes :info, :created_at, :updated_at, :vendor_class, :hardware_model

node(:hosts_count) { |model| hosts_count[model] }
