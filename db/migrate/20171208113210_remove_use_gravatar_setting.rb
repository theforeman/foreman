class RemoveUseGravatarSetting < ActiveRecord::Migration[4.2]
  def up
    Setting.where(:name => 'use_gravatar').delete_all
  end

  def down
    Setting.create!(:name => 'use_gravatar', :description => N_("Foreman will use gravatar to display user icons"),
                    :default => false, :full_name => N_('Use Gravatar'))
  end
end
