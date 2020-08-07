namespace :seed do
  desc 'Generate various forgeries. This should not be used in production'
  task :forgeries => %w[forgeries:all]

  namespace :forgeries do
    task :load_factories => :environment do
      if Rails.env.production?
        STDERR.puts "Refusing to seed data in a production environment"
        exit 1
      end

      begin
        require 'factory_bot'
      rescue LoadError
        STDERR.puts "Factory bot is unavailable"
        exit 1
      end

      FactoryBot.find_definitions
    end

    task :domains => :load_factories do
      names = ['example.com', 'example.org', 'example.net']

      User.as_anonymous_admin do
        Organization.all.each do |organization|
          Organization.current = organization
          # TODO: Select a number of locations? All?
          locations = []
          generate(Domain, get_desired(5)) do |count, generator|
            FactoryBot.create(:domain,
              :name => build_domain(names, generator),
              :organizations => [organization],
              :locations => locations)
          end
        end
      end
    end

    task :hosts => :load_factories do
      User.as_anonymous_admin do
        domains = Domain.all
        organizations = Organization.all
        operatingsystems = Operatingsystem.all
        owner = User.anonymous_admin

        generate(Host::Managed, get_desired(100)) do |count, generator|
          os = operatingsystems.sample

          Organization.current = organizations.sample
          domains = Domain.all

          FactoryBot.create(:host,
            :hostname => generator.next_random_name,
            :domain => domains.sample,
            :operatingsystem => os,
            :architecture => os.architectures.sample,
            :organization => Organization.current,
            :owner => owner)
        end
      end
    end

    task :operatingsystems => :load_factories do
      User.as_anonymous_admin do
        build_operatingsystems.each do |os|
          unless Operatingsystem.find_by(:name => os.name, :major => os.major, :minor => os.minor)
            os.save!
            puts "Created #{os}"
          end
        end
      end
    end

    task :organizations => :load_factories do
      User.as_anonymous_admin do
        generate(Organization, get_desired(10)) do |count, generator|
          FactoryBot.create(:organization, :name => generator.next_random_name)
        end
      end
    end

    task :all => [:operatingsystems, :organizations, :domains, :hosts] do
    end

    def get_desired(default)
      (ENV['COUNT'] || default).to_i
    end

    def generate(model, desired)
      generator = NameGenerator.new
      current_size = model.all.size
      step = (ENV['STEP'] || 1).to_i

      print "Found #{current_size}/#{desired} #{model.model_name.plural}. "
      needed = desired - current_size

      if needed > 0
        puts "Generating #{needed} #{model.model_name.plural}"
        needed.times do |count|
          yield count, generator
          print '.' if count % step
        end

        # Put an end of line if we every printed progress
        puts if needed >= step
      else
        puts 'Nothing to do'
      end
    end

    def build_operatingsystems
      architectures = Architecture.all

      [
        # Red Hat
        FactoryBot.build(:operatingsystem, :name => 'RedHat', :major => '6', :architectures => architectures),
        FactoryBot.build(:operatingsystem, :name => 'RedHat', :major => '7', :architectures => architectures),
        # CentOS
        FactoryBot.build(:operatingsystem, :name => 'CentOS', :major => '6', :architectures => architectures),
        FactoryBot.build(:operatingsystem, :name => 'CentOS', :major => '7', :architectures => architectures),
        # Debian
        FactoryBot.build(:operatingsystem, :name => 'Debian', :major => '8', :minor => '8', :release_name => 'jessie', :architectures => architectures),
        FactoryBot.build(:operatingsystem, :name => 'Debian', :major => '9', :minor => '0', :release_name => 'stretch', :architectures => architectures),
        # Ubuntu
        FactoryBot.build(:operatingsystem, :name => 'Ubuntu', :major => '12', :minor => '04', :release_name => 'precise', :architectures => architectures),
        FactoryBot.build(:operatingsystem, :name => 'Ubuntu', :major => '14', :minor => '04', :release_name => 'trusty', :architectures => architectures),
        FactoryBot.build(:operatingsystem, :name => 'Ubuntu', :major => '16', :minor => '04', :release_name => 'xenial', :architectures => architectures),
      ]
    end

    def build_domain(names, generator)
      parts = [generator.next_random_name]
      parts << generator.next_random_name if rand() < 0.3
      parts << generator.next_random_name if rand() < 0.1
      parts << names.sample

      parts.join('.')
    end
  end
end
