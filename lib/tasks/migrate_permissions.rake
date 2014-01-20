desc 'migrate foreman permissions from 1.3 to 1.4'
task :migrate_permissions => :environment do
  puts 'This script will migrate existing role and permissions to new version'
  puts 'before you continue, please make a backup in case something goes wrong!'
  puts
  puts "Every role's permission will be assigned via unlimited filter."
  puts 'For every user having some filters we will create clones of their'
  puts ' roles and convert these old filters to new scoped filters.'
  puts
  puts 'If you think you can define your permissions better you can delete all'
  puts 'existing roles manually a recreate them with filters according to you needs.'
  puts "However you'll have to run this script then anyway so builtin roles are converted as well."
  puts
  puts 'Ready to continue? <yes|no>'
  exit(0) unless $stdin.gets =~ /^yes/

  backup_prompt

  puts 'Ready, steady, go!'
  begin
    ActiveRecord::Base.transaction do
      # STEP 1 - migrate roles
      # for all role permissions we'll create unlimited filters
      # we'll group permissions into filters by their resource
      roles = Role.all
      roles.each do |role|

        # role without permissions? nothing to do then
        if role.attributes['permissions'].nil?
          puts "no old permissions found for role '#{role.name}', skipping"
          next
        end

        # permissions assigned to role which we want to migrate
        permission_names = YAML.load(role.attributes['permissions'])

        # role without permissions but with YAML record
        if permission_names.blank?
          puts "Clearing old permissions for role '#{role.name}'"
          if Role.update_all("permissions = NULL", "id = #{role.id}") == 1
            puts "... OK"
          else
            raise "could not clear old permissions for role '#{role.name}'"
          end
          next
        end

        # check for unknown permissions, this should never happen, raise an exception if it does
        role_permissions = permission_names.map do |name|
          permission = Permission.find_by_name(name)
          raise "unknown permission #{name}" if permission.nil?
          permission
        end

        # we group permissions by resource the belong to
        # then create a filter per resource
        # and create a new relation between mapped permission and this filter
        role_permissions.group_by(&:resource_type).each do |resource, permissions|
          filter      = Filter.new
          filter.role = role
          filter.save!
          puts "Created an unlimited filter for role '#{role.name}'"

          permissions.each do |permission|
            filtering            = Filtering.new
            filtering.filter     = filter
            filtering.permission = Permission.find_by_name(permission.name)
            filtering.save!
            puts "... with permission '#{permission.name}'"
          end
        end

        # finally we clear old permissions from role so
        puts "Clearing old permissions for role '#{role.name}'"
        if Role.update_all("permissions = NULL", "id = #{role.id}") == 1
          puts "... OK"
        else
          raise "could not clear old permissions for role '#{role.name}'"
        end
      end

      # STEP 2 - migrate user filters
      # for every user having a filter we make copy of all his roles and add filtering scoped searches
      # to corresponding filters
      users = User.all
      users.each do |user|
        unless filtered?(user)
          puts "no filters found for user '#{user.login}', skipping"
          next
        end

        puts "Migrating user '#{user.login}'"
        puts "... cloning all roles"
        clones     = user.roles.builtin(false).map { |r| clone_role(r, user) }
        user.roles = clones + user.roles.builtin(true)
        puts "... done"

        filters                     = Hash.new { |h, k| h[k] = '' }

        # compute resources
        filters[:compute_resrouces] = search = user.compute_resources.uniq.map { |cr| "id = #{cr.id}" }.join(' or ')
        affected                    = clones.map(&:filters).flatten.select { |f| f.resource_type == 'ComputeResource' }
        affected.each do |filter|
          filter.update_attributes :search => search unless search.blank?
        end
        puts "... compute resource filters applied"

        # domains were not limited in old system, to keep it compatible, we don't convert it and use just search string
        # later for hosts
        filters[:domains]    = user.domains.uniq.map { |cr| "id = #{cr.id}" }.join(' or ')

        # host groups
        filters[:hostgroups] = search = user.hostgroups.uniq.map { |cr| "id = #{cr.id}" }.join(' or ')
        affected             = clones.map(&:filters).flatten.select { |f| f.resource_type == 'Hostgroup' }
        affected.each do |filter|
          filter.update_attributes :search => search unless search.blank?
        end
        puts "... hostgroups filters applied"

        # fact_values for hosts scope
        filters[:facts] = user.user_facts.uniq.map { |uf| "facts.#{uf.fact_name.name} #{uf.operator} #{uf.criteria}" }.join(' or ')

        search          = ''

        # owner_type
        if user.filter_on_owner
          user_cond  = "owner_id = #{user.id} and owner_type = User"
          group_cond = user.cached_usergroups.uniq.map { |g| "owner_id = #{g.id}" }.join(' or ')
          search     = "(#{user_cond})"
          search     += " or ((#{group_cond}) and owner_type = Usergroup)" unless group_cond.blank?
        end

        # normal filters - domains, compute resource, hostgroup, facts
        filter = filters[:domains].gsub('id', 'domain_id')
        search = user.domains_andor == 'and' ? "(#{search}) and (#{filter})" : "#{search} or (#{filter})" unless filter.blank?
        filter = filters[:compute_resources].gsub('id', 'compute_resource_id')
        search = user.compute_resources_andor == 'and' ? "(#{search}) and (#{filter})" : "#{search} or (#{filter})" unless filter.blank?
        filter = filters[:hostgroups].gsub('id', 'hostgroup_id')
        search = user.hostgroups_andor == 'and' ? "(#{search}) and (#{filter})" : "#{search} or (#{filter})" unless filter.blank?
        filter = filters[:facts]
        search = user.facts_andor == 'and' ? "(#{search}) and (#{filter})" : "#{search} or (#{filter})" unless filter.blank?

        # taxonomies
        if Settings[:organizations_enabled]
          filter = user.organizations.map { |o| "organization_id = #{o.id}" }.join(' or ')
          search = user.organizations_andor == 'and' ? "(#{search}) and (#{filter})" : "#{search} or (#{filter})" unless filter.blank?
        end
        if Settings[:locations_enabled]
          filter = user.locations.map { |o| "location_id = #{o.id}" }.join(' or ')
          search = user.locations_andor == 'and' ? "(#{search}) and (#{filter})" : "#{search} or (#{filter})" unless filter.blank?
        end

        # fix first and/or that could appear
        search = search.sub(/^ and /, '') if search.starts_with?(' and ')
        search = search.sub(/^ or /, '') if search.starts_with?(' or ')

        affected = clones.map(&:filters).flatten.select { |f| f.resource_type == 'Host' }
        affected.each do |filter|
          filter.update_attributes :search => search unless search.blank?
        end
        puts "... all other filters applied"

        puts "Removing old filter"
        user.domains           = []
        user.compute_resources = []
        user.hostgroups        = []
        user.facts             = []
        user.filter_on_owner   = false
        user.save!
        puts "... done"
      end
    end

  rescue => e
    puts "Error occured, transaction rollbacked\n #{e.message} - #{e.backtrace.join("\n")}"
  end
end

def filtered?(user)
  user.compute_resources.present? ||
      user.domains.present? ||
      user.hostgroups.present? ||
      user.facts.present? ||
      user.filter_on_owner
end

def clone_role(role, user)
  clone      = role.dup
  clone.name = role.name + "_#{user.login}"
  clone.save!

  role.filters.each { |f| clone_filter(f, clone) }

  clone.reload
end

def clone_filter(filter, role)
  clone             = filter.dup
  clone.permissions = filter.permissions
  clone.role        = role
  clone.save!
end

def backup_prompt
  puts 'Before you continue, would you like to auto-create a backup in case something goes wrong?'
  puts '<yes|no>'
  if $stdin.gets =~ /^yes/
    Rake::Task["db:dump"].invoke
  else
    while true
      puts 'Do you really want to continue without a backup?'
      puts 'Changes for this task cannot be rollbacked.'
      puts '<yes|no> - "yes" will start the migration without a backup'

      case $stdin.gets.strip
      when /\A[yY]es?\Z/
        return
      when /\A[nN]o?\Z/
        Rake::Task["db:dump"].invoke
      end
    end
  end
end

