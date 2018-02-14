class AddConfigReportsOrigin < ActiveRecord::Migration[5.1]
  def change
    add_column :reports, :origin, :string
  end
end
