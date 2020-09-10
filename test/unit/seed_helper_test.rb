require 'test_helper'
require Rails.root + 'db/seeds.d/020-roles_list.rb'

class SeedHelperTest < ActiveSupport::TestCase
  test "should create locked role" do
    role_name = "Test role"
    permissions_names = [:view_hosts, :destroy_hosts]
    refute Role.find_by(:name => role_name)
    SeedHelper.create_role role_name, {:permissions => permissions_names}, 0
    role = Role.find_by(:name => role_name)
    assert role
    assert_equal permissions_names.sort, role.permissions.pluck(:name).sort.map(&:to_sym)
  end

  test "should update a description for a role" do
    role_name = 'existing role'
    SeedHelper.create_role role_name, {:permissions => []}, 0
    role = Role.find_by(:name => role_name)
    refute_equal 'new description', role.description
    SeedHelper.create_role role_name, {:permissions => [], :description => 'new description'}, 0
    assert_equal 'new description', role.reload.description
  end

  test "should add new permissions to existing roles" do
    role_name = 'existing role'
    SeedHelper.create_role role_name, {:permissions => [:view_domains, :edit_domains]}, 0
    role = Role.find_by(:name => role_name)

    SeedHelper.create_role role_name, {:permissions => [:edit_domains, :create_domains]}, 0
    permissions = role.permissions.pluck(:name)
    # create new permissions
    assert_includes permissions, 'create_domains'
    # keeps existing permissions
    assert_includes permissions, 'edit_domains'
    # drops additional permissions
    refute_includes permissions, 'view_domains'
  end

  test "should not try add new permissions to existing roles if it's explicitly disabled, the permission might not exist e.g. while in migration" do
    role_name = 'existing role'
    SeedHelper.create_role role_name, {:permissions => [:view_domains, :edit_domains]}, 0
    role = Role.find_by(:name => role_name)

    SeedHelper.create_role role_name, {:permissions => [:edit_domains, :create_domains], :update_permissions => false}, 0
    permissions = role.permissions.pluck(:name)
    # does not create new permission
    refute_includes permissions, 'create_domains'
    # keeps existing permissions
    assert_includes permissions, 'edit_domains'
    assert_includes permissions, 'view_domains'
  end

  test 'Does not fail on modified default role' do
    role = Role.default
    role.add_permissions!(:view_domains)
    permissions = role.permissions.pluck(:name)
    assert_includes permissions, 'view_domains'

    name, opts = RolesList.default_role.first
    SeedHelper.create_role(name, opts, Role::BUILTIN_DEFAULT_ROLE)
    permissions = role.permissions.pluck(:name)
    assert_includes permissions, 'view_domains'
  end

  test 'Does not fail on modified default role with filter' do
    role = Role.default
    role.add_permissions!(:view_domains, search: 'name = example.com')
    permissions = role.permissions.pluck(:name)
    assert_includes permissions, 'view_domains'

    name, opts = RolesList.default_role.first
    SeedHelper.create_role(name, opts, Role::BUILTIN_DEFAULT_ROLE)
    permissions = role.permissions.pluck(:name)
    assert_includes permissions, 'view_domains'
    assert_includes role.filters.pluck(:search), 'name = example.com'
  end

  describe '#audit_modified?' do
    it "should recognize object was modified" do
      medium = Medium.last
      medium_name = medium.name
      refute SeedHelper.audit_modified?(Medium, medium.name)
      medium.update(:name => "renamed medium")
      assert SeedHelper.audit_modified?(Medium, medium_name)
    end

    context 'with attributes filtering' do
      let(:bookmark) { FactoryBot.create(:bookmark, :name => 'two', :public => true, :controller => 'config_reports') }

      it "recognizes irrelevant change" do
        refute SeedHelper.audit_modified?(Bookmark, bookmark.name, :controller => bookmark.controller)
        bookmark.update(:query => "name = barbar")
        bookmarks(:two).update(:name => 'modified irelevant')
        refute SeedHelper.audit_modified?(Medium, bookmark.name, :controller => bookmark.controller)
      end

      it "recognizes relevant changes in complex history" do
        old_name = bookmark.name
        refute SeedHelper.audit_modified?(Bookmark, bookmark.name, :controller => bookmark.controller)
        bookmark.update(:query => "name = barbar")
        bookmark.update(:name => 'modified')
        bookmark.update(:name => 'modified2')
        bookmark.update(:query => "name = bar2")
        assert SeedHelper.audit_modified?(Bookmark, old_name, :controller => bookmark.controller)
        bookmarks(:two).destroy
        bookmark.destroy
        assert SeedHelper.audit_modified?(Bookmark, old_name, :controller => bookmark.controller)
      end

      it "recognizes irrelevant changes in complex history" do
        refute SeedHelper.audit_modified?(Bookmark, bookmark.name, :controller => bookmark.controller)
        bookmarks(:two)
        bookmarks(:two).update(:name => 'modified')
        bookmarks(:two).update(:name => 'modified2')
        bookmarks(:two).destroy
        bookmark.update(:query => "name = barbar")
        refute SeedHelper.audit_modified?(Bookmark, bookmark.name, :controller => bookmark.controller)
      end
    end
  end

  describe '.import_raw_template' do
    def get_template(metadata_hash = nil)
      tpl = []
      if metadata_hash
        tpl << '<%#'
        tpl << YAML.dump(metadata_hash).split("\n")[1..-1].join("\n")
        tpl << '%>'
      end
      tpl << 'Template body'
      tpl.join("\n")
    end

    def mock_taxonomies(type, taxonomies)
      unscoped_mock = mock()
      unscoped_mock.stubs(:all).returns(taxonomies)
      type.stubs(:unscoped).returns(unscoped_mock)
    end

    let(:metadata) do
      {
        'name' => 'Test template',
        'model' => 'ProvisioningTemplate',
        'kind' => 'finish',
      }
    end

    it 'requires name in metadata' do
      ex = assert_raises RuntimeError do
        SeedHelper.import_raw_template(get_template(metadata.except('name')))
      end
      assert_match("Attribute 'name' is required", ex.message)
    end

    it 'requires template model in metadata' do
      ex = assert_raises RuntimeError do
        SeedHelper.import_raw_template(get_template(metadata.except('model')))
      end
      assert_match("Attribute 'model' is required", ex.message)
    end

    it 'skips templates that have been changed' do
      SeedHelper.expects(:audit_modified?).with(ProvisioningTemplate, 'Test template').returns(true)
      assert_nil SeedHelper.import_raw_template(get_template(metadata))
    end

    it 'skips template that have unknown model' do
      assert_nil SeedHelper.import_raw_template(get_template(metadata.merge({'model' => 'unknown'})))
    end

    it 'skips templates that require a missing plugin' do
      requirements = {
        'require' => [{
          'plugin' => 'unknown_plugin',
        }],
      }
      assert_nil SeedHelper.import_raw_template(get_template(metadata.merge(requirements)))
    end

    it 'skips templates that require a plugin in higher version' do
      requirements = {
        'require' => [{
          'plugin' => 'some_plugin',
          'version' => '2.0.1',
        }],
      }
      Foreman::Plugin.expects(:find).with('some_plugin').returns(mock(:version => '1.9'))
      assert_nil SeedHelper.import_raw_template(get_template(metadata.merge(requirements)))
    end

    it 'accepts prereleases to satisty version condition ' do
      requirements = {
        'require' => [{
          'plugin' => 'some_plugin',
          'version' => '2.0.1',
        }],
      }
      Foreman::Plugin.expects(:find).with('some_plugin').returns(mock(:version => '2.0.1.rc2'))
      refute_nil SeedHelper.import_raw_template(get_template(metadata.merge(requirements)))
    end

    it 'imports the template and sets taxonomies' do
      orgs = [taxonomies(:organization1), taxonomies(:organization2)]
      locs = [taxonomies(:location1), taxonomies(:location2)]

      mock_taxonomies(Organization, orgs)
      mock_taxonomies(Location, locs)

      tpl = SeedHelper.import_raw_template(get_template(metadata))
      assert(tpl.valid?)
      assert(tpl.persisted?)
      assert_equal(orgs, tpl.organizations)
      assert_equal(locs, tpl.locations)
    end

    it 'sets correct vendor' do
      tpl = SeedHelper.import_raw_template(get_template(metadata), 'SomePlugin')
      assert_equal('SomePlugin', tpl.vendor)
    end

    it 'does not touch taxonomies on update' do
      orgs = [taxonomies(:organization1), taxonomies(:organization2)]
      locs = [taxonomies(:location1), taxonomies(:location2)]

      mock_taxonomies(Organization, orgs)
      mock_taxonomies(Location, locs)

      tpl = SeedHelper.import_raw_template(get_template(metadata.merge({'name' => 'MyScript'})))
      assert_equal([], tpl.organizations)
      assert_equal([], tpl.locations)
    end

    it 'updates the template' do
      orgs = [taxonomies(:organization1), taxonomies(:organization2)]
      locs = [taxonomies(:location1), taxonomies(:location2)]

      mock_taxonomies(Organization, orgs)
      mock_taxonomies(Location, locs)

      template_body = get_template(metadata.merge({'name' => 'MyScript'}))

      tpl = SeedHelper.import_raw_template(template_body)
      assert(tpl.valid?)
      assert(tpl.persisted?)
      assert_equal(template_body, tpl.template)
    end
  end
end
