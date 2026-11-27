namespace :settings do
  desc 'Export a reference of all settings'
  task :reference => :environment do
    SettingRegistry.instance.sort_by(&:name).each do |setting|
      puts <<~SETTING

        ##### #{setting.name}

        #{setting.description}

        Default: `#{setting.default}`
      SETTING
    end
  end
end
