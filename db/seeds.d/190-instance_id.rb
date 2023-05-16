Setting[:instance_id] = Foreman.uuid unless Setting.where(name: 'instance_id').exists?
