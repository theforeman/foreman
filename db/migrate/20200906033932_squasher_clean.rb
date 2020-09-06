class SquasherClean < ActiveRecord::Migration[6.0]
  class SchemaMigration < ApplicationRecord
  end

  def up
    migrations = Dir.glob(File.join(__dir__, '*.rb'))
    versions = migrations.map { |file| File.basename(file)[/\A\d+/] }
    SchemaMigration.where("version NOT IN (?)", versions).delete_all
  end

  def down
  end
end
