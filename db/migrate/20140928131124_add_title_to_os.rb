class AddTitleToOs < ActiveRecord::Migration[4.2]
  def up
    add_column :operatingsystems, :title, :string, :limit => 255

    Operatingsystem.reset_column_information
    Operatingsystem.unscoped.each do |os|
      os.title = os.to_label
      os.save_without_auditing
    end
  end

  def down
    remove_column :operatingsystems, :title
  end
end
