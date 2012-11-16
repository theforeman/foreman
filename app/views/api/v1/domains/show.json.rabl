object @domain
attributes :id, :name, :fullname, :dns_id

child :domain_parameters do
   attributes :id, :name, :value, :reference_id, :type, :priority, :created_at, :updated_at
end
