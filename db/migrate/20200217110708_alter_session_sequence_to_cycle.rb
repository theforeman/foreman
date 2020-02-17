class AlterSessionSequenceToCycle < ActiveRecord::Migration[5.2]
  def up
    change_column :sessions, :id, :bigint
    if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
      ActiveRecord::Base.connection.execute(<<-SQL)
        ALTER SEQUENCE sessions_id_seq MAXVALUE 9223372036854775807 CYCLE;
      SQL
    end
  end

  def down
  end
end
