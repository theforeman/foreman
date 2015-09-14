object @os_default_template

attributes :id,
           :provisioning_template_id,
           :provisioning_template_name,
           :template_kind_id,
           :template_kind_name,
           :operatingsystem_id,
           :operatingsystem_name
attributes :provisioning_template_id => :config_template_id,
           :provisioning_template_name => :config_template_name
