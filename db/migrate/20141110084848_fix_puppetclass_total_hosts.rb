class FixPuppetclassTotalHosts < ActiveRecord::Migrati
  def up
    if User.anonymous_admin(false) && Puppetclass.count > 0
      User.current = User.anonymous_admin
      Puppetclass.all.each(&:update_total_hosts)
    else
      puts "Migration #{self.class.name} will be rescheduled during db:seed"
    end
  end

  def down
  end
end
