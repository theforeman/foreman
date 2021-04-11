object @setting

extends "api/v2/settings/base"

attributes :description, :settings_type, :default, :created_at, :updated_at

node :value do |s|
  s.safe_value
end

node :category do |s|
  s.category_name
end

node :category_name do |s|
  s.category_label
end

node :readonly do |s|
  s.readonly?
end

node :config_file do |s|
  s.config_file
end

node :encrypted do |s|
  s.encrypted?
end

node :select_values do |s|
  s.select_values
end
