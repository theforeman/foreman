class IndexForeignKeysInComputeResources < ActiveRecord::Migration[5.1]
  def change
    add_index :compute_resources, :http_proxy_id
  end
end
