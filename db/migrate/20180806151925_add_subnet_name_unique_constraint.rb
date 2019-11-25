class AddSubnetNameUniqueConstraint < ActiveRecord::Migration[5.1]
  def up
    deduplicator = Migrations::DeduplicateSubnets.new
    say_with_time("Deduplicating the following subnet names: #{deduplicator.duplicate_names.inspect}") do
      deduplicator.run
    end

    add_index :subnets, :name, :unique => true
  end

  def down
    remove_index :subnets, :name
  end
end
