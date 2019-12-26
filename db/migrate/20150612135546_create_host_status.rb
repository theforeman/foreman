class CreateHostStatus < ActiveRecord::Migration[4.2]
  def up
    create_table :host_status do |t|
      t.string :type, :limit => 255
      t.integer :status, :default => 0, :null => false, :limit => 5
      t.references :host, :null => false
      t.datetime :reported_at, :null => false
    end
    add_index :host_status, :host_id
    add_foreign_key "host_status", "hosts", :name => "host_status_hosts_host_id_fk", :column => 'host_id'
    add_column :hosts, :global_status, :integer, :default => 0, :null => false

    success = true
    Host.includes(:host_statuses, :last_report_object).find_each do |host|
      host.skip_orchestration! # disable orchestration
      success &= update_statuses(host)
    ensure
      host.enable_orchestration!
    end
    say "some host status could not be saved, please see the log for more details" unless success

    remove_column :hosts, :puppet_status
  end

  def down
    add_column :hosts, :puppet_status, :bigint, :null => false, :default => 0
    remove_column :hosts, :global_status
    remove_foreign_key "host_status", :name => "host_status_hosts_host_id_fk"
    remove_index :host_status, :host_id

    Host.includes(:host_statuses).find_each do |host|
      config_status = host.host_statuses.find_by_type("HostStatus::ConfigurationStatus")
      unless config_status.nil?
        host.puppet_status = config_status.status
        host.save
      end
    end

    drop_table :host_status
  end

  private

  def update_statuses(host)
    results = HostStatus.status_registry.map do |status_class|
      status = host.get_status(status_class)
      update_sub_status(status)
    end

    if results.any?
      host.host_statuses.reload
      host.refresh_global_status

      unless (saved = host.save(:validate => false))
        logger.warn "Skipping global status refresh for host #{host.name}"
      end
      results.push saved
    end

    !results.include?(false)
  end

  # returns array of true/false/nil
  # true means sub status is updated
  # false means some error
  # nil means status is not relevant
  def update_sub_status(status)
    if status.relevant?
      status.refresh!
      true
    end
  rescue => e
    # if the status is not ready to be saved because of missing migration
    # we skip it and let it refresh by itself
    logger.warn "skipping sub-status #{status.class} refresh, it's not ready - #{e.message}"
    false
  end
end
