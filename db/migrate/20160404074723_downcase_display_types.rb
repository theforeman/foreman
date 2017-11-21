class DowncaseDisplayTypes < ActiveRecord::Migration[4.2]
  def up
    Foreman::Model::Libvirt.all.each do |cr|
      downcased = cr.display_type.downcase
      if cr.display_type != downcased
        cr.display_type = downcased
        cr.save
      end
    end
  end
end
