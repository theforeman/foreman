class AssignFqdnToHostName < ActiveRecord::Migration[6.1]
  def up
    Host.find_in_batches(batch_size: 1000) do |hosts|
      hosts.each do |host|
        host.update_attribute(:name, host.fqdn)
      end
    end
  end
end
