object @setting

extends "api/v2/settings/base"

attributes :description, :category, :settings_type, :default, :created_at, :updated_at
node :value do |s|
  s.safe_value
end

node :category_name do |s|
  _(s.class.humanized_category || s.category.gsub(/Setting::/, ''))
end
