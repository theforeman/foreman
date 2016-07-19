class ChangeTemplatesTypeDefault < ActiveRecord::Migration
  def up
    change_column_default :templates, :type, 'Template'
  end

  def down
    change_column_default :templates, :type, 'ConfigTemplate'
  end
end
