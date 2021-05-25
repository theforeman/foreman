class EnforceUniqueTemplates < ActiveRecord::Migration[6.0]
  def up
    # Duplicates should only occur when two concurrent seeds hit a race condition,
    # so it should be safe to drop any duplicates, preferring the newest one
    Template.where.not(id: Template.group(:name, :type).pluck("max(id)")).each do |template|
      say "Deleting duplicate #{template.type.underscore.humanize}: #{template.name}"
      template.update_columns(locked: false)
      template.destroy
    end

    add_index :templates, [:type, :name], unique: true
  end

  def down
    remove_index :templates, [:type, :name]
  end
end
