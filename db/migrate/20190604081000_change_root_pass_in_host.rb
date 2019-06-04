class ChangeRootPassInHost < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      change_table :hosts do |t|
        dir.up   { t.change :root_pass, :text }
        dir.down { t.change :root_pass, :string, limit: 255 }
      end

      change_table :hostgroups do |t|
        dir.up   { t.change :root_pass, :text }
        dir.down { t.change :root_pass, :string, limit: 255 }
      end
    end
  end
end
