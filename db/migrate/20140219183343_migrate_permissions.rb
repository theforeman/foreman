# we need permissions to be seeded already
require Rails.root + 'db/seeds.d/030-permissions'

# Fake models to make sure that this migration can be executed even when
# original models changes later (e.g. add validation on columns that are not
# present at this moment)
class FakePermission < ApplicationRecord
  self.table_name = 'permissions'
end

class FakeFilter < ApplicationRecord
  self.table_name = 'filters'
  # we need this for polymorphic relation to work, it has class name hardcoded in AR
  def self.name
    'Filter'
  end
  belongs_to :role, :class_name => 'FakeRole'
  has_many :filterings, :dependent => :destroy, :foreign_key => 'filter_id'
  has_many :permissions, :through => :filterings

  def resource_type
    @resource_type ||= permissions.first.try(:resource_type)
  end

  taxonomy_join_table = :taxable_taxonomies
  has_many taxonomy_join_table, :dependent => :destroy, :as => :taxable, :foreign_key => 'taxable_id'
  has_many :locations, -> { where(:type => 'Location') }, :through => taxonomy_join_table, :source => :taxonomy,
           :validate => false
  has_many :organizations, -> { where(:type => 'Organization') }, :through => taxonomy_join_table, :source => :taxonomy,
           :validate => false
end

class FakeUserRole < ApplicationRecord
  self.table_name = 'user_roles'
  belongs_to :owner, :polymorphic => true
  belongs_to :role, :class_name => 'FakeRole'
end

class FakeRole < ApplicationRecord
  self.table_name = 'roles'
  has_many :filters, :dependent => :destroy, :class_name => 'FakeFilter', :foreign_key => 'role_id'
  has_many :permissions, :through => :filters, :class_name => 'FakePermission', :foreign_key => 'permission_id'
end

class FakeFiltering < ApplicationRecord
  self.table_name = 'filterings'
  belongs_to :filter, :class_name => 'FakeFilter'
  belongs_to :permission, :class_name => 'FakePermission'
end

class FakeUser < ApplicationRecord
  self.table_name = 'users'
  # we need this for polymorphic relation to work, it has class name hardcoded in AR
  def self.name
    'User'
  end

  has_and_belongs_to_many :compute_resources, :join_table => "user_compute_resources", :foreign_key => 'user_id'
  has_and_belongs_to_many :domains, :join_table => "user_domains", :foreign_key => 'user_id'
  has_many :user_hostgroups, :dependent => :destroy, :foreign_key => 'user_id'
  has_many :hostgroups, :through => :user_hostgroups
  has_many :user_facts, :dependent => :destroy, :foreign_key => 'user_id'
  has_many :facts, :through => :user_facts, :source => :fact_name
  has_many :user_roles, -> { where(:owner_type => 'User') }, :dependent => :destroy, :foreign_key => 'owner_id',
           :class_name => 'FakeUserRole'
  has_many :roles, :through => :user_roles, :dependent => :destroy, :class_name => 'FakeRole'
  taxonomy_join_table = :taxable_taxonomies
  has_many taxonomy_join_table, :dependent => :destroy, :as => :taxable, :foreign_key => 'taxable_id'
  has_many :locations, -> { where(:type => 'Location') }, :through => taxonomy_join_table, :source => :taxonomy,
            :validate => false
  has_many :organizations, -> { where(:type => 'Organization') }, :through => taxonomy_join_table, :source => :taxonomy,
           :validate => false
  has_many :cached_usergroup_members, :foreign_key => 'user_id'
  has_many :cached_usergroups, :through => :cached_usergroup_members, :source => :usergroup
end

class MigratePermissions < ActiveRecord::Migration[4.2]
  # STEP 0 - add missing permissions to DB
  # some engines could have defined new permissions during their initialization
  # but permissions table hadn't existed yet so we check all registered
  # permissions and create those that are missing in database
  def make_sure_all_permissions_are_present
    engine_permissions = Foreman::AccessControl.permissions.select { |p| p.engine.present? }
    engine_permissions.each do |permission|
      FakePermission.where(:name => permission.name, :resource_type => permission.resource_type).first_or_create
    end
  end

  # STEP 1 - migrate roles
  # for all role permissions we'll create unlimited filters
  # we'll group permissions into filters by their resource
  def migrate_roles
    roles = FakeRole.all
    roles.each do |role|
      # role without permissions? nothing to do then
      if role.attributes['permissions'].nil?
        say "no old permissions found for role '#{role.name}', skipping"
        next
      end

      # permissions assigned to role which we want to migrate
      permission_names = YAML.load(role.attributes['permissions'])

      # role without permissions but with YAML record
      if permission_names.blank?
        clear_old_permission(role)
        next
      end

      # filter out unknown permissions, this could be leftovers from an old plugin.
      role_permissions = FakePermission.where(:name => permission_names)

      # we group permissions by resource the belong to
      # then create a filter per resource
      # and create a new relation between mapped permission and this filter
      role_permissions.group_by(&:resource_type).each do |resource, permissions|
        filter = FakeFilter.new
        filter.role = role
        filter.save!
        say "Created an unlimited filter for role '#{role.name}'"

        permissions.each do |permission|
          filtering            = FakeFiltering.new
          filtering.filter     = filter
          filtering.permission = FakePermission.find_by_name(permission.name)
          filtering.save!
          say "... with permission '#{permission.name}'"
        end
      end

      # finally we clear old permissions from role so
      clear_old_permission(role)
    end
  end

  def self.clear_old_permission(role)
    say "Clearing old permissions for role '#{role.name}'"
    if FakeRole.update_all("permissions = NULL", "id = #{role.id}") == 1
      say "... OK"
    else
      raise "could not clear old permissions for role '#{role.name}'"
    end
  end

  # STEP 2 - migrate user filters
  # for every user having a filter we make copy of all his roles and add filtering scoped searches
  # to corresponding filters
  def migrate_user_filters
    users = FakeUser.all
    users.each do |user|
      unless filtered?(user)
        say "no filters found for user '#{user.login}', skipping"
        next
      end

      say "Migrating user '#{user.login}'"
      say "... cloning all roles"
      user.roles = clones = user.roles.map { |r| clone_role(r, user) }
      say "... done"

      filters = Hash.new { |h, k| h[k] = '' }

      # compute resources
      filters[:compute_resources] = search = user.compute_resources.distinct.map { |cr| "id = #{cr.id}" }.join(' or ')
      affected                    = clones.map(&:filters).flatten.select { |f| f.resource_type == 'ComputeResource' }
      affected.each do |filter|
        filter.update :search => search if search.present?
      end
      say "... compute resource filters applied"

      # domains were not limited in old system, to keep it compatible, we don't convert it and use just search string
      # later for hosts
      filters[:domains]    = user.domains.distinct.map { |cr| "id = #{cr.id}" }.join(' or ')

      # host groups
      filters[:hostgroups] = search = user.hostgroups.distinct.map { |cr| "id = #{cr.id}" }.join(' or ')
      affected             = clones.map(&:filters).flatten.select { |f| f.resource_type == 'Hostgroup' }
      affected.each do |filter|
        filter.update :search => search if search.present?
      end
      say "... hostgroups filters applied"

      # fact_values for hosts scope
      filters[:facts] = user.user_facts.distinct.map { |uf| "facts.#{uf.fact_name.name} #{uf.operator} #{uf.criteria}" }.join(' or ')

      search, orgs, locs = convert_filters_to_search(filters, user)

      affected = clones.map(&:filters).flatten.select { |f| f.resource_type == 'Host' }
      affected.each do |filter|
        filter.organizations = orgs
        filter.locations = locs
        filter.update :search => search if search.present?
      end
      say "... all other filters applied"

      say "Removing old filter"
      user.domains           = []
      user.compute_resources = []
      user.hostgroups        = []
      user.facts             = []
      user.filter_on_owner   = false
      user.save!
      say "... done"
    end
  end

  def convert_filters_to_search(filters, user)
    search = ''

    # owner_type
    if user.filter_on_owner
      user_cond = "owner_id = #{user.id} and owner_type = User"
      group_cond = user.cached_usergroups.distinct.map { |g| "owner_id = #{g.id}" }.join(' or ')
      search = "(#{user_cond})"
      search += " or ((#{group_cond}) and owner_type = Usergroup)" if group_cond.present?
    end

    # normal filters - domains, compute resource, hostgroup, facts
    filter = filters[:domains].gsub('id', 'domain_id')
    if filter.present?
      search = "(#{search}) #{user.domains_andor} " if search.present?
      search = "#{search}(#{filter})"
    end

    filter = filters[:compute_resources].gsub('id', 'compute_resource_id')
    if filter.present?
      search = "(#{search}) #{user.compute_resources_andor} " if search.present?
      search = "#{search}(#{filter})"
    end

    filter = filters[:hostgroups].gsub('id', 'hostgroup_id')
    if filter.present?
      search = "(#{search}) #{user.hostgroups_andor} " if search.present?
      search = "#{search}(#{filter})"
    end

    filter = filters[:facts]
    if filter.present?
      search = "(#{search}) #{user.facts_andor} " if search.present?
      search = "#{search}(#{filter})"
    end

    # taxonomies
    orgs = user.organizations
    locs = user.locations

    [search, orgs, locs]
  end

  def filtered?(user)
    user.compute_resources.present? ||
        user.domains.present? ||
        user.hostgroups.present? ||
        user.facts.present? ||
        user.filter_on_owner
  end

  def clone_role(role, user)
    clone         = role.dup
    clone.name    = role.name + "_#{user.login}"
    clone.builtin = 0
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

  # To detect whether migration is needed we use existing models
  # fakes would always indicate that migration is needed
  def old_permissions_present
    user = User.new
    Role.column_names.include?('permissions') &&
        user.respond_to?(:compute_resources) &&
        user.respond_to?(:domains) &&
        user.respond_to?(:hostgroups) &&
        user.respond_to?(:facts) &&
        user.respond_to?(:filter_on_owner)
  end

  def up
    if old_permissions_present
      make_sure_all_permissions_are_present
      migrate_roles
      migrate_user_filters

      CacheManager.set_cache_setting(true)
      Rake::Task['db:migrate'].enhance nil do
        Rake::Task['fix_db_cache'].invoke
      end
    else
      say 'Skipping migration of permissions, since old permissions are not present'
    end
  end

  def down
    say 'Permission data migration is impossible, skipping'
  end
end
