object @hostgroup

extends "api/v2/hostgroups/base"

attributes :subnet_id, :subnet_name, :operatingsystem_id, :operatingsystem_name, :domain_id, :domain_name,
           :environment_id, :environment_name, :compute_profile_id, :compute_profile_name, :ancestry,
           :created_at, :updated_at
