Spork.prefork do
  unless ActiveRecord::Base.connection.table_exists?(:test_facets)
    ActiveRecord::Base.connection.create_table :test_facets do |t|
      # :id is created automatically
      t.integer :host_id
    end
  end
end
