class DropUnnecessaryTimestamps < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      [
        :cached_user_roles,
        :cached_usergroup_members,
        :fact_names,
        :fact_values,
        :settings,
        :taxable_taxonomies,
        :taxonomies,
      ].each do |table|
        change_table table do |t|
          dir.up do
            remove_column table, :created_at
            remove_column table, :updated_at
          end
          dir.down do
            t.timestamps
            table.classify.constantize.update_all(created_at: Time.now.utc, updated_at: Time.now.utc)
          end
        end
      end
    end
  end
end

