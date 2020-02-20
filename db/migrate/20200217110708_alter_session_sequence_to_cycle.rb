class AlterSessionSequenceToCycle < ActiveRecord::Migration[5.2]
  def up
    if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
      change_column :sessions, :id, :bigint
      pg_version = ActiveRecord::Base.connection.select_value('SHOW server_version_num').to_i
      if pg_version < 100000
        sql = "ALTER SEQUENCE sessions_id_seq MAXVALUE 9223372036854775807 CYCLE"
      else
        sql = "ALTER SEQUENCE sessions_id_seq AS bigint CYCLE"
      end
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def down
  end
end
