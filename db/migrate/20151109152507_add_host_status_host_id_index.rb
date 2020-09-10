class AddHostStatusHostIdIndex < ActiveRecord::Migration[4.2]
  def up
    # Remove all but the first status per host/type combination
    duplicate_statuses = HostStatus::Status.having('count(*) > 1').group(:host_id, :type).select(['host_id', 'type'])
    duplicate_statuses.each do |row|
      HostStatus::Status.where(:type => row[:type], :host_id => row[:host_id]).offset(1).destroy_all
    end

    add_index :host_status, [:type, :host_id], :unique => true
  end

  def down
    remove_index :host_status, [:type, :host_id]
  end
end
