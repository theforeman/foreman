class EnsureOsMinorIsNotNil < ActiveRecord::Migration[6.0]
  def up
    User.without_auditing do
      Operatingsystem.unscoped.find_each do |os|
        unless os.minor
          os.minor = ''
          os.save(validate: false)
        end
      end
    end
  end
end
