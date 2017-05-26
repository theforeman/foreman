class AddProducerToReports < ActiveRecord::Migration
  def change
    add_column :reports, :producer, :string
  end
end
