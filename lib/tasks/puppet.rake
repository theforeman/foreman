# Author: Roberto Moral Denche (Telmo : telmox@gmail.com)
# Description: The tasks defined in this Rakefile will help you populate some of the
#		fiels in GNI with what is already present in your database from 
#		StoragedConfig.

namespace :puppet do
    namespace :migrate do
	desc "Populates the Operating Systems in GNI based on your StoredConfig DB"
	task :populate_operatingsystem => :environment do
		helper = Array.new
		Host.all.each do |hosts|
			name = hosts.fact(:operatingsystem)[0].value 
			major = hosts.fact(:operatingsystemrelease)[0].value
			if name and major
			 helper << { name => major }
			end
		end
		helper.uniq!.each do |os|
			os.each_pair do |n, m|
				Operatingsystem.find_or_create_by_name_and_major n, m
			end
		end
	end

	desc "Assign the correct operatingsystem_id to the hosts based on StoredConfig"
	task :assign_operatingsystem => :environment do
		Host.all.each do |hosts|
			# Saving the host will fail if Host.mac is empty... so lets make sure its not.
			if not hosts.mac or hosts.mac == ""
				hosts.mac = hosts.fact(:macaddress)[0].value
			end

			if not hosts.operatingsystem_id
			os = hosts.fact(:operatingsystem)[0].value
				if os
					od_id = Operatingsystem.find_by_name(os).id
					hosts.operatingsystem_id = os_id
					hosts.save
				end
			end
		end
	end

	desc "Populates the Environments in GNI based on your StoredConfig DB"
	task :populate_environment => :environment do
		if FactName.find_by_name("environment")
			helper = Array.new
			Host.all.each do |hosts|
				environment = hosts.fact(:environment)[0].value
				if environment
					helper << environment
				end
			end

			helper.uniq!.each do |env|
				Environment.find_or_create_by_name env
			end
		end
	end

	desc "Assign the correct environment_id to the hosts based on StoredConfig"
	task :assign_environment => :environment do
		Host.all.each do |hosts|
			# Saving the host will fail if Host.mac is empty... so lets make sure its not.
			if not hosts.mac or hosts.mac == ""
				hosts.mac = hosts.fact(:macaddress)[0].value
			end

			if not hosts.environment_id
			env = hosts.fact(:environment)[0].value
				if env
					env_id = Environment.find_by_name(env).id
					hosts.environment_id = env_id
					hosts.save!
				end
			end
		end
	end

	desc "Migrate your puppet based hosts information to GNI"
	task :all => [ :populate_operatingsystem, :populate_environment, :assign_operatingsystem, :assign_environment ] do
		# Empty tasks
	end
    end
end
