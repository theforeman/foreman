require 'test_helper'
require 'seed_helper'
require 'database_cleaner'

class SeedsTest < ActiveSupport::TestCase
  # Disable AR transactional tests as we use DatabaseCleaner's truncation
  # to empty the DB of fixtures for testing the seed script
  self.use_transactional_tests = false

  setup do
    DatabaseCleaner.clean_with :truncation
    # Since we truncate the db, settings getter/setter won't work properly
    Setting.stubs(:[])
    Setting.stubs(:[]=)
    Setting.stubs(:[]).with(:bcrypt_cost).returns(1)
    Setting.stubs(:[]=).with(:bcrypt_cost, anything).returns(true)
    BCrypt::Engine.stubs(:calibrate).returns(4)
    Foreman.stubs(:in_rake?).returns(true)
  end

  def seed(*seed_files)
    # Authorisation is disabled usually when run from a rake db:* task
    as_admin do
      seed_files = ['../seeds.rb'] if seed_files.empty?
      seed_files.each do |file|
        load File.expand_path("../../../db/seeds.d/#{file}", __dir__)
      end
    end
  end

  teardown do
    User.current = nil
  end

  test 'calibrates bcrypt cost' do
    BCrypt::Engine.expects(:calibrate).returns(4)
    seed
  end

  test 'populates multiple tables' do
    Setting.stubs(:[]).with(:authorize_login_delegation_auth_source_user_autocreate).returns('EXTERNAL')
    tables = [Feature, Ptable, ProvisioningTemplate, Medium, Bookmark, AuthSourceExternal]

    tables.each do |model|
      assert model.unscoped.count.zero?
    end

    seed

    tables.each do |model|
      refute model.unscoped.count.zero?
    end

    refute Ptable.unscoped.where(:os_family => nil).any?
    refute Medium.unscoped.where(:os_family => nil).any?
    Dir["#{Rails.root}/app/views/unattended/**/*.erb"].each do |tmpl|
      template = File.read(tmpl)
      requirements = Template.parse_metadata(template)['require'] || []
      # skip templates that require plugins that aren't available
      next unless SeedHelper.send(:test_template_requirements, tmpl, requirements)
      if tmpl =~ /partition_tables_templates/
        assert Ptable.unscoped.where(:template => template).any?, "No partition table containing #{tmpl}"
      elsif tmpl =~ /report_templates/
        assert ReportTemplate.unscoped.where(:template => template).any?, "No report template containing #{tmpl}"
      else
        assert ProvisioningTemplate.unscoped.where(:template => template).any?, "No template containing #{tmpl}"
      end
    end
  end

  test 'populates hidden admin users' do
    assert_difference 'User.unscoped.where(:login => [User::ANONYMOUS_ADMIN, User::ANONYMOUS_API_ADMIN]).count', 2 do
      seed('030-auth_sources.rb', '035-admin.rb')
    end
    [User::ANONYMOUS_ADMIN, User::ANONYMOUS_API_ADMIN, User::ANONYMOUS_CONSOLE_ADMIN].each do |login|
      user = User.unscoped.find_by_login(login)
      assert user.present?, "cannot find user #{login}"
      assert user.password_hash.blank?
      assert user.password_salt.blank?
      assert user.admin?
      assert user.hidden?
      assert_valid user
    end
  end

  context 'populating an initial admin user' do
    test 'with defaults' do
      assert_difference 'User.unscoped.where(:login => "admin").count', 1 do
        seed('030-auth_sources.rb', '035-admin.rb')
      end
      user = User.unscoped.find_by_login('admin')
      assert user.password_hash.present?
      assert user.password_salt.present?
      assert user.admin?
      assert_valid user
    end

    test 'with environment overrides' do
      assert_difference 'User.unscoped.where(:login => "seed_test").count', 1 do
        with_env('SEED_ADMIN_USER'       => 'seed_test',
                 'SEED_ADMIN_PASSWORD'   => 'seed_secret',
                 'SEED_ADMIN_FIRST_NAME' => 'Seed',
                 'SEED_ADMIN_LAST_NAME'  => 'Test',
                 'SEED_ADMIN_EMAIL'      => 'seed@example.net') do
          seed
        end
      end
      user = User.unscoped.find_by_login('seed_test')
      assert user.matching_password? 'seed_secret'
      assert user.admin?
      refute user.hidden?
      assert_valid user
    end
  end

  test 'is idempotent' do
    seed
    ActiveRecord::Base.any_instance.expects(:save).never
    seed
  end

  test "does update template that was not modified by user" do
    seed('070-provisioning_templates.rb')
    ProvisioningTemplate.without_auditing { ProvisioningTemplate.unscoped.find_by_name('Kickstart default').update(:template => 'test') }
    seed('070-provisioning_templates.rb')
    refute_equal ProvisioningTemplate.unscoped.find_by_name('Kickstart default').template, 'test'
  end

  test "doesn't add a template back that was deleted" do
    seed('070-provisioning_templates.rb')
    with_auditing(ProvisioningTemplate) do
      assert_equal 1, ProvisioningTemplate.unscoped.where(:name => 'Kickstart default').destroy_all.size
    end
    assert SeedHelper.audit_modified?(ProvisioningTemplate, 'Kickstart default')
    seed('070-provisioning_templates.rb')
    refute ProvisioningTemplate.unscoped.find_by_name('Kickstart default')
  end

  test "doesn't add a template back that was renamed" do
    seed('070-provisioning_templates.rb')
    with_auditing(ProvisioningTemplate) do
      tmpl = ProvisioningTemplate.unscoped.find_by_name('Kickstart default')
      tmpl.name = 'test'
      tmpl.save!
    end
    assert SeedHelper.audit_modified?(ProvisioningTemplate, 'Kickstart default')
    seed('070-provisioning_templates.rb')
    refute ProvisioningTemplate.unscoped.find_by_name('Kickstart default')
  end

  test "no audits are recorded" do
    seed
    assert_equal [], Audit.all
  end

  test "seed organization when environment SEED_ORGANIZATION specified" do
    Organization.stubs(:none?).returns(true)
    with_env('SEED_ORGANIZATION' => 'seed_test') do
      seed('030-auth_sources.rb', '035-admin.rb', '050-taxonomies.rb')
    end
    assert Organization.unscoped.find_by_name('seed_test')
  end

  test "don't seed organization when an org already exists" do
    Organization.stubs(:none?).returns(false)
    with_env('SEED_ORGANIZATION' => 'seed_test') do
      seed('030-auth_sources.rb', '035-admin.rb', '050-taxonomies.rb')
    end
    refute Organization.unscoped.find_by_name('seed_test')
  end

  test "seed location when environment SEED_LOCATION specified" do
    Location.stubs(:none?).returns(true)
    with_env('SEED_LOCATION' => 'seed_test') do
      seed('030-auth_sources.rb', '035-admin.rb', '050-taxonomies.rb')
    end
    assert Location.unscoped.find_by_name('seed_test')
  end

  test "don't seed location when a location already exists" do
    Location.stubs(:none?).returns(false)
    with_env('SEED_LOCATION' => 'seed_test') do
      seed('030-auth_sources.rb', '035-admin.rb', '050-taxonomies.rb')
    end
    refute Location.unscoped.find_by_name('seed_test')
  end

  test "seeded organization contains seeded location" do
    Location.stubs(:none?).returns(true)
    Organization.stubs(:none?).returns(true)

    org_name = 'seed_org'
    loc_name = 'seed_loc'

    with_env('SEED_ORGANIZATION' => org_name, 'SEED_LOCATION' => loc_name) do
      seed('030-auth_sources.rb', '035-admin.rb', '050-taxonomies.rb')
    end

    org = Organization.unscoped.find_by_name(org_name)
    loc = Location.unscoped.find_by_name(loc_name)

    assert org.locations.include?(loc)
  end

  test "all access permissions are created by permissions seed" do
    seed('020-permissions_list.rb', '030-permissions.rb')
    access_permissions = Foreman::AccessControl.permissions.reject(&:public?).reject(&:plugin?).map(&:name).map(&:to_s)
    seeded_permissions = Permission.pluck('permissions.name')
    # Check all access control have a matching seeded permission
    assert_equal [], access_permissions - seeded_permissions
    # Check all seeded permissions have a matching access control
    # except for 'escalate_roles' as it is not tied to a controller action
    assert_equal [], seeded_permissions - access_permissions - ['escalate_roles']
  end

  test "viewer role contains all view permissions except for settings" do
    seed('020-permissions_list.rb', '030-permissions.rb', '020-roles_list.rb', '040-roles.rb')
    view_permissions = Permission.all.select { |permission| permission.name.match(/view/) && permission.name != 'view_settings' }
    assert_equal [], view_permissions - Role.unscoped.find_by_name('Viewer').permissions
  end

  test "adds description to template kind" do
    seed('070-provisioning_templates.rb')
    tmpl_kind = TemplateKind.unscoped.find_by_name('iPXE')
    assert_equal "Used in iPXE environments.", tmpl_kind.description
  end
end
