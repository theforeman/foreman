# Author: Roberto Moral Denche (Telmo : telmox@gmail.com)
# Description: The tasks defined in this Rakefile will help you populate some of the
#    fields in Foreman with what is already present in your database from
#    StoragedConfig.
require 'rake/clean'
require 'yaml'

namespace :puppet do
  namespace :import do
    desc "Imports hosts and facts from existings YAML files, use dir= to override default directory"
    task :hosts_and_facts, [:dir] => :environment do |t, args|
      dir = args[:dir] || ENV['dir'] || '/opt/puppetlabs/server/data/puppetserver/yaml/facts'
      puts "Importing from #{dir}"
      Dir["#{dir}/*.yaml"].each do |yaml|
        name = yaml.match(/.*\/(.*).yaml/)[1]
        puts "Importing #{name}"
        puppet_facts = File.read(yaml)
        facts_stripped_of_class_names = YAML.safe_load(puppet_facts.gsub(/\!ruby\/object.*$/, ''))
        User.as_anonymous_admin do
          host = Host::Managed.import_host(facts_stripped_of_class_names['name'], 'puppet')
          HostFactImporter.new(host).import_facts(facts_stripped_of_class_names['values'])
        end
      end
    end
  end

  namespace :migrate do
    desc "
    Migrate Puppet configuration from Host and Hostgroup attributes to parameters.
    This task is relevant if you want to continue using Puppet provisioning,
    but do not want to install the Puppet plugin and get the full ENC funcionality."

    task :to_parameters => :environment do
      class FakeEnv < ::ApplicationRecord
        self.table_name = 'environments'
      end

      def add_host_param(host, name, value)
        param = HostParameter.find_by(host: host, name: name)
        if !param
          HostParameter.create(host: host, name: name, value: value)
        elsif param.value != value
          puts "Parameter '#{name} = #{value}' for Host '#{host.name}' could not be defined because it is already defined on Host with value #{param.value}"
        end
      end

      def add_hostgroup_param(hostgroup, name, value)
        param = GroupParameter.find_by(hostgroup: hostgroup, name: name)
        if !param
          GroupParameter.create(hostgroup: hostgroup, name: name, value: value)
        elsif param.value != value
          puts "Parameter '#{name} = #{value}' for Hostgroup '#{hostgroup.title}' could not be defined because it is already defined on Hostgroup with value #{param.value}"
        end
      end

      User.current = User.anonymous_console_admin
      envs = Hash[FakeEnv.all.pluck(:id, :name)]

      hg_at = Hostgroup.arel_table
      hg_arel = hg_at[:environment_id].not_eq(nil)
      hg_arel = hg_arel.or(hg_at[:puppet_proxy_id].not_eq(nil))
      hg_arel = hg_arel.or(hg_at[:puppet_ca_proxy_id].not_eq(nil))
      Hostgroup.where(hg_arel).preload(:puppet_proxy, :puppet_ca_proxy).find_each(batch_size: 100) do |hg|
        add_hostgroup_param(hg, 'puppet_environment', envs[hg.environment_id]) if hg.environment_id
        add_hostgroup_param(hg, 'puppet_server', hg.puppet_server) if hg.puppet_proxy_id
        add_hostgroup_param(hg, 'puppet_ca_server', hg.puppet_ca_server) if hg.puppet_ca_proxy_id
      end

      Host.where.not(environment_id: nil).preload(:puppet_proxy, :puppet_ca_proxy).find_each(batch_size: 100) do |host|
        add_host_param(host, 'puppet_environment', envs[host.environment_id])
        add_host_param(host, 'puppet_server', host.puppet_server) if host.puppet_proxy_id
        add_host_param(host, 'puppet_ca_server', host.puppet_ca_server) if host.puppet_ca_proxy_id
      end
    end
  end
end
