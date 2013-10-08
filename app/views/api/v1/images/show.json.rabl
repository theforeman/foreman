object @image

attributes :id, :operatingsystem_id, :compute_resource_id, :architecture_id, :uuid, :username, :name, :created_at, :updated_at,
           :operatingsystem_name, :compute_resource_name, :architecture_name
attribute :iam_role, :if => lambda { |img| img.compute_resource.kind_of? Foreman::Model::EC2 }
