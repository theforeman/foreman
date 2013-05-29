class AddDefaultConsoleToSettings < ActiveRecord::Migration
  def self.up
	Setting.create(
		:name => 'default_console_address',
		:description => 'The ip address that should be used for the console listen address when provisioning new virtual machines when using Libvirt',
		:category => 'Provisioning',
		:default => '0'
	)
  end

  def self.down
	Setting.find_by_name('default_console_address').destroy
  end
end

