desc "Show dependencies in nicely-formatted output"
namespace :bundler do
  task :deps => :environment do
    groups = {}
    Bundler.definition.dependencies.each do |dep|
      dep.groups.each do |group|
        groups[group] = [] if groups[group].nil?
        groups[group] << "#{dep.name} #{dep.requirements_list.inspect}"
      end
    end

    groups.sort.map do |group, deps|
      puts "Group #{group}"
      deps.sort.each do |dep|
        puts " #{dep}"
      end
    end
  end
end
