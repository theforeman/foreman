object @taxonomy
attributes :id, :name,
            :organization_ids, :hostgroup_ids,
            :environment_ids, :domain_ids, :medium_ids,
            :subnet_ids, :compute_resource_ids,
            :smart_proxy_ids, :user_ids, :config_template_ids
attribute :ignore_types => :select_all_types