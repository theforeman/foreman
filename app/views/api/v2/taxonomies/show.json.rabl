object @taxonomy

extends "api/v2/taxonomies/main"

attributes  :organization_ids, :hostgroup_ids,
            :environment_ids, :domain_ids, :medium_ids,
            :subnet_ids, :compute_resource_ids,
            :smart_proxy_ids, :user_ids, :config_template_ids,
            :created_at, :updated_at

attribute :ignore_types => :select_all_types
