unless ActiveRecord::Base.connection.table_exists?(:test_facets)
  ActiveRecord::Base.connection.create_table :test_facets do |t|
    # :id is created automatically
    t.integer :host_id
  end
end
unless ActiveRecord::Base.connection.table_exists?(:module_test_facets)
  ActiveRecord::Base.connection.create_table :module_test_facets do |t|
    # :id is created automatically
    t.integer :host_id
  end
end
unless ActiveRecord::Base.connection.table_exists?(:test_hostgroup_facets)
  ActiveRecord::Base.connection.create_table :test_hostgroup_facets do |t|
    # :id is created automatically
    t.integer :hostgroup_id
  end
end
unless ActiveRecord::Base.connection.table_exists?(:test_host_and_hostgroup_facets)
  ActiveRecord::Base.connection.create_table :test_host_and_hostgroup_facets do |t|
    # :id is created automatically
    t.integer :hostgroup_id
    t.integer :host_id
  end
end
