collection @datastores, :root => "datastores", :object_root => "datastore"
attributes :name
node(:free) { |datastore| number_to_human_size(datastore.freespace) }
node(:prov) { |datastore| number_to_human_size(datastore.capacity + (datastore.uncommitted || 0) - datastore.freespace) }
node(:total) { |datastore| number_to_human_size(datastore.capacity) }
