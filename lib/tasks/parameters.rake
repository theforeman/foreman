desc 'Reset parameter priorities in case they were changed'
namespace :parameters do
  task :reset_priorities => :environment do
    Parameter.reorder('').distinct.pluck(:type).each do |type|
      priority = Parameter.type_priority(type)
      Parameter.reorder('').where(type: type).update_all(priority: priority)
    end
  end
end
