class MigrateTemplateInputValueType < ActiveRecord::Migration[6.0]
  def up
    TemplateInput.where(value_type: 'search').update_all(value_type: 'autocomplete')
    TemplateInput.where(value_type: 'date').update_all(value_type: 'dateTime')
  end
end
