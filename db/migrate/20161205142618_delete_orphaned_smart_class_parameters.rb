class DeleteOrphanedSmartClassParameters < ActiveRecord::Migration
  def up
    PuppetclassLookupKey.where("NOT EXISTS (SELECT * FROM environment_classes WHERE environment_classes.puppetclass_lookup_key_id = lookup_keys.id)").destroy_all
  end

  def down
  end
end
