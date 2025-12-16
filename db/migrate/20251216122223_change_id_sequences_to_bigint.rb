# Fix up the sequences to match columns from 20170110113824_change_id_value_range
class ChangeIdSequencesToBigint < ActiveRecord::Migration[7.0]
  def up
    change_sequence :logs, as: :bigint
    change_sequence :reports, as: :bigint
    change_sequence :fact_values, as: :bigint
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def change_sequence(table_name, as:)
    execute("ALTER SEQUENCE #{default_sequence_name(table_name)} AS #{as}")
  end
end
