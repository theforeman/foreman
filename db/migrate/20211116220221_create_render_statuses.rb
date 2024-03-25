class CreateRenderStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :render_statuses do |t|
      t.references :host, type: :integer, foreign_key: true, index: true
      t.references :hostgroup, type: :integer, foreign_key: true, index: true
      t.references :template, type: :integer, foreign_key: true, index: true, null: false
      t.boolean :safemode, null: false
      t.boolean :success, null: false
      t.timestamps
    end

    add_index :render_statuses, [:host_id, :template_id, :safemode], unique: true, name: 'index_render_statuses_on_host_and_template_and_safemode'
    add_index :render_statuses, [:hostgroup_id, :template_id, :safemode], unique: true, name: 'index_render_statuses_on_hostgroup_and_template_and_safemode'

    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE render_statuses ADD CONSTRAINT host_or_hostgroup_check CHECK (
            (
              (host_id is not null)::integer +
              (hostgroup_id is not null)::integer
            ) = 1
          );
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE render_statuses DROP CONSTRAINT host_or_hostgroup_check;
        SQL
      end
    end
  end
end
