class UpdatePuppetclassLookupKeysWithPuppetclass < ActiveRecord::Migration
  def up
    say_with_time "updating puppetclass_lookup_keys records - this may take a long time to process" do
      Puppetclass.all.each do |pc|
        pc_lookup_key_ids = pc.class_params.map(&:id)
        if pc_lookup_key_ids.length > 0
          begin
            PuppetclassLookupKey.where(id: pc_lookup_key_ids).update_all(:puppetclass_id => pc.id)
          rescue => e
            puts "Puppetclass #{pc.id} with #{pc_lookup_key_ids.inspect}: #{e} - ignoring these records"
          end
        end
      end
    end
  end

  def down
  end
end
