class DeleteOrphanedSmartClassParameters < ActiveRecord::Migration[4.2]
  def up
    LookupValue.joins(:lookup_key).where("NOT EXISTS (SELECT * FROM environment_classes WHERE environment_classes.puppetclass_lookup_key_id = lookup_keys.id) AND lookup_keys.type = 'PuppetclassLookupKey'").delete_all
    PuppetclassLookupKey.where("NOT EXISTS (SELECT * FROM environment_classes WHERE environment_classes.puppetclass_lookup_key_id = lookup_keys.id)").delete_all
  end

  def down
  end
end
