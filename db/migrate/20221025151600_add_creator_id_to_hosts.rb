class AddCreatorIdToHosts < ActiveRecord::Migration[6.1]
  def change
    add_reference :hosts, :creator, foreign_key: { to_table: :users, on_delete: :nullify }
  end
end
