class AddBuildErrorsToHosts < ActiveRecord::Migration[5.1]
  def change
    add_column :hosts, :initiated_at, :datetime
    add_column :hosts, :build_errors, :text
  end
end
