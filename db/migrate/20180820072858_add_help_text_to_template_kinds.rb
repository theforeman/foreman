class AddHelpTextToTemplateKinds < ActiveRecord::Migration[5.1]
  def change
    add_column :template_kinds, :description, :text
  end
end
