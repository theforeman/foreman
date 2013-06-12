namespace :vmware do
  desc 'Reset vmware compute resource public keys in the database'
  task :reset => :environment do
    User.unscoped.as :admin do
      Foreman::Model::Vmware.all.map{|cr| cr.attrs[:pubkey_hash] = "" ;cr.save}
    end
  end
end
