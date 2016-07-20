class UpdateHostStatusStatusFieldInt < ActiveRecord::Migration[4.2]
  def up
    # Report::BIT_NUM is 6 bits per metric, times 6 metrics = ~5 bytes
    change_column :host_status, :status, :integer, :limit => 5
  end

  def down
    change_column :host_status, :status, :integer, :limit => nil
  end
end
