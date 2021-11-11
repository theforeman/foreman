class DropFixDbCacheSetting < ActiveRecord::Migration[6.0]
  def up
    Setting.where(name: 'fix_db_cache').delete_all
  end
end
