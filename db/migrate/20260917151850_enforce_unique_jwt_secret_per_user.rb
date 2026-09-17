class EnforceUniqueJwtSecretPerUser < ActiveRecord::Migration[7.0]
  def up
    delete_duplicates(:jwt_secrets, :user_id)
    remove_index :jwt_secrets, :name => 'index_jwt_secrets_on_user_id'
    add_index :jwt_secrets, :user_id, :unique => true, :name => 'index_jwt_secrets_on_user_id'

    delete_duplicates(:registration_facets, :host_id)
    remove_index :registration_facets, :name => 'index_registration_facets_on_host_id'
    add_index :registration_facets, :host_id, :unique => true, :name => 'index_registration_facets_on_host_id'
  end

  def down
    remove_index :jwt_secrets, :name => 'index_jwt_secrets_on_user_id'
    add_index :jwt_secrets, :user_id, :name => 'index_jwt_secrets_on_user_id'

    remove_index :registration_facets, :name => 'index_registration_facets_on_host_id'
    add_index :registration_facets, :host_id, :name => 'index_registration_facets_on_host_id'
  end

  private

  # Duplicates are create-race losers with no independent identity to rename, so drop
  # them. Keep the oldest; it's the one has_one/find_by already tend to serve.
  def delete_duplicates(table, column)
    sql = "SELECT string_agg(id::text, ',' ORDER BY id) FROM #{table} GROUP BY #{column} HAVING COUNT(*) > 1"
    connection.select_values(sql).each do |ids|
      keeper, *extras = ids.split(',')
      say "#{table}: keeping id #{keeper}, deleting #{extras.size} duplicate(s): #{extras.join(', ')}"
      connection.execute("DELETE FROM #{table} WHERE id IN (#{extras.join(',')})")
    end
  end
end
