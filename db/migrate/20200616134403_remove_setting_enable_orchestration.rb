class RemoveSettingEnableOrchestration < ActiveRecord::Migration[6.0]
  def up
    Setting.where(:name => 'enable_orchestration_on_fact_import').delete_all
  end
end
