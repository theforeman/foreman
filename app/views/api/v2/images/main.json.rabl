object @image

extends "api/v2/images/base"

attributes :operatingsystem_id, :operatingsystem_name, :compute_resource_id, :compute_resource_name,
           :architecture_id, :architecture_name, :uuid, :username, :created_at, :updated_at

attribute :user_data, :if => lambda { |img| img.compute_resource.user_data_supported? }

attribute :iam_role, :if => lambda { |img| img.compute_resource.kind_of? Foreman::Model::EC2 }
