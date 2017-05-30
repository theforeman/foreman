class DestroyPuppetclassLookupKeysWithEmptyPuppetclass < ActiveRecord::Migration
  def up
    say_with_time "destroying puppetclass_lookup_keys records with empty puppetclass - this may take a long time to process" do
      pc_lookup_keys_with_empty_puppetclass = PuppetclassLookupKey.where(puppetclass_id: nil)
      puts "there are #{pc_lookup_keys_with_empty_puppetclass.length} records to delete"
      pc_lookup_keys_with_empty_puppetclass.destroy_all
    end
  end

  def down
  end
end
