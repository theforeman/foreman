class AlterSessionSequenceToCycle < ActiveRecord::Migration[5.2]
  def up
    if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
      change_column :sessions, :id, :bigint
      version = Gem::Version.new(ActiveRecord::Base.connection.select_value('SHOW server_version'))
      if version < Gem::Version.new('10')
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
