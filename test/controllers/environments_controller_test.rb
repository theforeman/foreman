require 'test_helper'

class EnvironmentsControllerTest < ActionController::TestCase
  setup do
    @model = Environment.first
  end

  basic_index_test
  basic_new_test
  basic_edit_test
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test "should create new environment" do
    assert_difference 'Environment.unscoped.count' do
      post :create, params: { :commit => "Create", :environment => {:name => "some_environment"} }, session: set_session_user
    end
    assert_redirected_to environments_path
  end

  test "should update environment" do
    setup_users
    environment = Environment.new :name => "some_environment"
    assert environment.save!

    put :update, params: { :commit => "Update", :id => environment.name, :environment => {:name => "other_environment"} }, session: set_session_user
    env = Environment.unscoped.find(environment.id)
    assert env.name == "other_environment"

    assert_redirected_to environments_path
  end

  test "should destroy environment" do
    setup_users
    environment = Environment.new :name => "some_environment"
    assert environment.save!

    assert_difference('Environment.unscoped.count', -1) do
      delete :destroy, params: { :id => environment.name }, session: set_session_user
    end

    assert_redirected_to environments_path
  end

  def setup_import_classes
    as_admin do
      Host::Managed.update_all(:environment_id => nil)
      Hostgroup.update_all(:environment_id => nil)
      Puppetclass.destroy_all
      Environment.destroy_all
    end
    @request.env["HTTP_REFERER"] = environments_url
    # This is the database status
    # and should result in a db_tree of {"env1" => ["a", "b", "c"], "env2" => ["a", "b", "c"]}
    orgs = [taxonomies(:organization1)]
    locs = [taxonomies(:location1)]
    as_admin do
      klasses = ["a", "b", "c"].map { |name| FactoryBot.create :puppetclass, :name => name }
      ["env1", "env2"].each do |name|
        env = FactoryBot.create :environment, :name => name, :organizations => orgs, :locations => locs
        env.puppetclasses += klasses
      end
    end
    # This is the on-disk status
    # and should result in a disk_tree of {"env1" => ["a", "b", "c"],"env2" => ["a", "b", "c"]}
    envs = HashWithIndifferentAccess.new(:env1 => %w{a b c}, :env2 => %w{a b c})
    pcs = [HashWithIndifferentAccess.new("a" => { "name" => "a", "module" => "", "params" => {}})]
    classes = Hash[pcs.map { |k| [k.keys.first, Foreman::ImporterPuppetclass.new(k.values.first)] }]
    Environment.expects(:puppetEnvs).returns(envs).at_least(0)
    ProxyAPI::Puppet.any_instance.stubs(:environments).returns(["env1", "env2"])
    ProxyAPI::Puppet.any_instance.stubs(:classes).returns(classes)
  end

  test "should import as admin when organization changed" do
    setup_import_classes
    Organization.current = taxonomies(:organization2)
    post :obsolete_and_new, params:
      { "changed" =>
        {"new" =>
          {"env1" => '{"a":{"new":{}}}'},
        },
      }, session: set_session_user
    assert_redirected_to environments_url
  end

  test "should handle disk environment containing additional classes" do
    setup_import_classes
    Environment.find_by_name("env1").puppetclasses.delete(Puppetclass.find_by_name("a"))
    #    db_tree   of {"env1" => ["b", "c"],     "env2" => ["a", "b", "c"]}
    #    disk_tree of {"env1" => ["a", "b", "c"],"env2" => ["a", "b", "c"]}
    get :import_environments, params: { :proxy => smart_proxies(:puppetmaster) }, session: set_session_user
    assert_template "common/_puppetclasses_or_envs_changed"
    assert_select 'input#changed_new_env1'
    post :obsolete_and_new, params:
      { "changed" =>
        {"new" =>
          {"env1" => '{"a":{"new":{}}}'},
        },
      }, session: set_session_user
    assert_redirected_to environments_url
    assert_equal "Successfully updated environments and Puppet classes from the on-disk Puppet installation", flash[:success]
    assert_equal ["a", "b", "c"],
      Environment.unscoped.find_by_name("env1").puppetclasses.map(&:name).sort
  end

  test "should handle disk environment containing less classes" do
    setup_import_classes
    as_admin { Puppetclass.create(:name => "d") }
    Environment.find_by_name("env1").puppetclasses << Puppetclass.find_by_name("d")
    # db_tree   of {"env1" => ["a", "b", "c", "d"], "env2" => ["a", "b", "c"]}
    # disk_tree of {"env1" => ["a", "b", "c"],      "env2" => ["a", "b", "c"]}
    get :import_environments, params: { :proxy => smart_proxies(:puppetmaster) }, session: set_session_user
    assert_template "common/_puppetclasses_or_envs_changed"
    assert_select 'input#changed_obsolete_env1[value*="d"]'
    post :obsolete_and_new,
      params: { "changed" =>
        {"obsolete" =>
          {"env1" => '["d"]'},
        },
      }, session: set_session_user
    assert_redirected_to environments_url
    assert_equal "Successfully updated environments and Puppet classes from the on-disk Puppet installation", flash[:success]
    envs = Environment.unscoped.find_by_name("env1").puppetclasses.map(&:name).sort
    assert_equal ["a", "b", "c"], envs
  end
  test "should handle disk environment containing less environments" do
    setup_import_classes
    as_admin { Environment.create(:name => "env3") }
    # db_tree   of {"env1" => ["a", "b", "c"], "env2" => ["a", "b", "c"], "env3" => []}
    # disk_tree of {"env1" => ["a", "b", "c"], "env2" => ["a", "b", "c"]}
    get :import_environments, params: { :proxy => smart_proxies(:puppetmaster).id }, session: set_session_user
    assert_template "common/_puppetclasses_or_envs_changed"
    assert_select 'input#changed_obsolete_env3'
    post :obsolete_and_new, params:
      { "changed" =>
        {"obsolete" =>
          {"env3" => '[]'},
        },
      }, session: set_session_user
    assert_redirected_to environments_url
    assert_equal "Successfully updated environments and Puppet classes from the on-disk Puppet installation", flash[:success]
    assert_equal [], Environment.unscoped.find_by_name("env3").puppetclasses.map(&:name).sort
  end

  test "should fail to remove active environments" do
    disable_orchestration
    setup_import_classes
    as_admin do
      host = FactoryBot.create(:host)
      Environment.find_by_name("env1").puppetclasses += [puppetclasses(:one)]
      host.environment_id = Environment.find_by_name("env1").id
      assert host.save!
      assert host.errors.empty?
      assert Environment.find_by_name("env1").hosts.count > 0
    end

    # assert_template "puppetclasses_or_envs_changed". This assertion will fail. And it should fail. See above.
    post :obsolete_and_new, params:
      { "changed" =>
       {"obsolete" =>
        {"env1" => '["a","b","c","_destroy_"]'},
       },
     }, session: set_session_user
    assert Environment.unscoped.find_by_name("env1").hosts.count > 0
    # assert flash[:error] =~ /^Failed to update the environments and puppetclasses from the on-disk puppet installation/
    assert Environment.unscoped.find_by_name("env1")
  end

  test "should obey config/ignored_environments.yml" do
    @request.env["HTTP_REFERER"] = environments_url
    setup_import_classes
    as_admin do
      Environment.create :name => "env3"
      Environment.find_by_name("env2").destroy
    end
    # db_tree   of {"env1" => ["a", "b", "c"], "env3" => []}
    # disk_tree of {"env1" => ["a", "b", "c"], "env2" => ["a", "b", "c"]}

    PuppetClassImporter.any_instance.stubs(:ignored_environments).returns(["env1", "env2", "env3"])
    get :import_environments, params: { :proxy => smart_proxies(:puppetmaster) }, session: set_session_user

    assert_equal "No changes to your environments detected\nIgnored environments: env1, env2, and env3", flash[:info]
  end

  test "should obey puppet class filters in config/ignored_environments.yml" do
    setup_import_classes
    PuppetClassImporter.any_instance.stubs(:updated_classes_for).returns([])
    PuppetClassImporter.any_instance.stubs(:removed_classes_for).returns([])

    PuppetClassImporter.any_instance.stubs(:ignored_environments).returns([])
    PuppetClassImporter.any_instance.stubs(:ignored_classes).returns([/^a$/])
    get :import_environments, params: { :proxy => smart_proxies(:puppetmaster) }, session: set_session_user

    assert_equal "No changes to your environments detected\nIgnored classes in the environments: env1 and env2", flash[:info]
  end

  test 'it adds a warning when boolean keys are found' do
    setup_import_classes
    PuppetClassImporter.any_instance.stubs(:ignored_environments).returns([true])

    get :import_environments, params: { :proxy => smart_proxies(:puppetmaster) }, session: set_session_user
    assert_equal "Ignored environment names resulting in booleans found. Please quote strings like true/false and yes/no in config/ignored_environments.yml", flash[:warning]
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit an environment' do
    setup_user
    get :edit, params: { :id => environments(:production).name }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing environments' do
    setup_user
    get :index, session: set_session_user
    assert_response :success
  end

  test "should accept environment with name 'name'" do
    @request.env["HTTP_REFERER"] = environments_url
    ProxyAPI::Puppet.any_instance.stubs(:environments).returns(["new"])
    post :obsolete_and_new, params:
      { "changed" =>
       {"new" =>
        {"new" => '{"a":{"new":{}}}'},
       },
    }, session: set_session_user
    assert(Environment.unscoped.all.map(&:name).include?('new'), 'Should include environment with name "new"')
  end
end
