class UpdateStiType < ActiveRecord::Migration
  def up
    execute "UPDATE systems SET type='Host::Base' WHERE type='System::Base'"
    execute "UPDATE systems SET type='Host::Managed' WHERE type='System::Managed'"
    execute "UPDATE systems SET type='Host::Discovered' WHERE type='System::Discovered'"
    execute "UPDATE parameters SET type='HostParameter' WHERE type='SystemParameter'"
  end

  def down
    execute "UPDATE systems SET type='System::Base' WHERE type='Host::Base'"
    execute "UPDATE systems SET type='System::Managed' WHERE type='Host::Managed'"
    execute "UPDATE systems SET type='System::Discovered' WHERE type='Host::Discovered'"
    execute "UPDATE parameters SET type='SystemParametere' WHERE type='HostParameter'"
  end

end
