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

  # TRANSLATORS: do not translate
  desc <<~END_DESC
    Generate dummy reports and display performance numbers. Half of lines are unique,
    half are same. Reports will be expired via cron or can be expired manually or
    by deleting all hosts named hostXX.example.com.

    Available conditions:
      * origin           => Puppet or Ansible
      * hosts            => number of newly created hosts
      * reports          => number of reports per host
      * lines            => number of lines per report

      Example:
        rake reports:generate hosts=20 reports=100 lines=200
  END_DESC
  task :reports => :environment do
    def randn
      rand(100_000)
    end

    def make_report(origin, host = 1, logs = 100)
      is_ansible = origin =~ /Ansible/i
      is_puppet = origin =~ /Puppet/i
      metrics = if is_puppet
                  { "time" => { "config_retrieval" => 6.98906397819519, "total" => 13.8197405338287 },
                    "resources" => { "applied" => 0, "failed" => 1, "failed_restarts" => 0, "out_of_sync" => 0, "restarted" => 0, "scheduled" => 67, "skipped" => 0, "total" => 68 }, "changes" => { "total" => 0 } }
                elsif is_ansible
                  { "metrics" => {"time" => { "total": 37 } }}
                else
                  {}
                end
      base = {
        "host" => "host#{host}.example.com", "reported_at" => Time.now.utc.to_s,
        "status" => {
          "applied" => host,
          "restarted" => host * 2,
          "failed" => host * 3,
          "failed_restarts" => 0,
          "skipped" => 1,
          "pending" => 9999999,
        },
        "metrics" => metrics,
        "logs" => []
      }
      (1..logs).each do |i|
        src = if is_ansible
                "common : Copy default motd %s" % (i.even? ? randn : 0)
              elsif is_puppet
                "//Node/Puppet[%s]" % (i.even? ? randn : 0)
              else
                "A unique message %s" % (i.even? ? randn : 0)
              end
        msg = if is_ansible
                "{\"_ansible_parsed\": true, \"group\": \"root\", \"uid\": 0, \"checksum\": \"%s\", \"changed\": false, \"owner\": \"root\", \"state\": \"file\", \"gid\": 0, \"mode\": \"0644\", \"diff\": {\"after\": {\"path\": \"/etc/motd\"}, \"before\": {\"path\": \"/etc/motd\"}}, \"invocation\": {\"module_args\": {\"directory_mode\": null, \"force\": false, \"remote_src\": null, \"path\": \"/etc/motd\", \"owner\": \"root\", \"follow\": false, \"group\": \"root\", \"unsafe_writes\": null, \"state\": \"file\", \"content\": null, \"serole\": null, \"diff_peek\": null, \"setype\": null, \"dest\": \"/etc/motd\", \"selevel\": null, \"original_basename\": \"motd.txt\", \"regexp\": null, \"validate\": null, \"src\": \"motd.txt\", \"seuser\": null, \"recurse\": false, \"delimiter\": null, \"mode\": null, \"attributes\": null, \"backup\": null}}, \"path\": \"/etc/motd\", \"size\": 1090, \"_ansible_no_log\": false}" % (i.even? ? Digest::SHA1.hexdigest(randn.to_s) : "0a381ff6a86081af6dc957a77c7e2017a3244c4c")
              elsif is_puppet
                "A Puppet message"
              else
                "A message"
              end
        base["logs"].append({
                              "log" => { "sources" => { "source" => src },
                              "messages" => { "message" => msg },
                              "level" => (i.even? ? "notice" : "err") },
                            })
      end
      base["reporter"] = "ansible" if is_ansible
      base
    end

    User.as_anonymous_admin do
      Rails.logger.level = Logger::ERROR
      Foreman::Logging.logger('permissions').level = Logger::ERROR
      Foreman::Logging.logger('audit').level = Logger::ERROR
      origin = ENV['origin'] || 'Puppet'
      hosts = ENV['hosts'] || 10
      reports = ENV['reports'] || 50
      lines = ENV['lines'] || 100
      total_time = 0
      (1..reports).each do |i|
        host_id = i % hosts
        report = make_report(origin, host_id + 1, lines)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
        ConfigReport.import(report)
        total_time += Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond) - start_time
      end
      puts "Total records in the db: #{Host::Base.unscoped.all.count} hosts, #{Report.unscoped.all.count} reports"
      puts "Time spent: #{total_time.to_f / (10**9)} seconds"
      puts "Import rate: #{reports.to_f / (total_time / (10**9))} r/s"
    end
  end
end
