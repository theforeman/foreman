object @config_template

attributes :name, :template, :snippet, :audit_comment, :id
attributes :template_kind_id, :operatingsystem_ids, :unless => lambda {|t| t.snippet?}
