extends "api/v2/settings/main"

attributes :readonly?

node :config_file do |s|
  s.class.config_file
end

child :select_values => :select_values do
  extends "settings/setting_value_selection"
end
