object @template_combination

attributes :id,
           :provisioning_template_id,
           :provisioning_template_name,
           :hostgroup_id,
           :hostgroup_name,
           :environment_id,
           :environment_name
attributes :provisioning_template_id => :config_template_id,
           :provisioning_template_name => :config_template_name
