class RemoveLimitFromGrubPass < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      change_table :hosts do |t|
        dir.up { t.change :grub_pass, :text, limit: nil }
        dir.down { t.change :grub_pass, :string, limit: 255 }
      end

      change_table :hostgroups do |t|
        dir.up { t.change :grub_pass, :text, limit: nil }
        dir.down { t.change :grub_pass, :string, limit: 255 }
      end
    end
  end
end
