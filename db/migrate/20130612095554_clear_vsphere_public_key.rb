class ClearVspherePublicKey < ActiveRecord::Migration
  def up
    User.unscoped.as :admin do
      Foreman::Model::Vmware.all.map{|cr| cr.attrs[:pubkey_hash] = "" ;cr.save}
    end
  end

  def down
  end
end
