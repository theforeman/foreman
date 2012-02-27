require 'test_helper'

class EnvironmentsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns(:environments)
  end

  test "should get json index" do
    get :index, {:format => "json"}, set_session_user

    envs = ActiveSupport::JSON.decode(@response.body)
    assert !envs.empty?
    assert_response :success
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
  end

  test "should create new environment" do
    assert_difference 'Environment.count' do
      post :create, { :commit => "Create", :environment => {:name => "some_environment"} }, set_session_user
    end
    assert_redirected_to environments_path
  end

  test "should create new environment json" do
    assert_difference 'Environment.count' do
      post :create, {:format => "json", :commit => "Create", :environment => {:name => "some_environment"} }, set_session_user
    end
    env = ActiveSupport::JSON.decode(@response.body)
    assert env["environment"]["name"] = "some_environment"
    assert_response :created
  end

  test "should get edit" do
    environment = Environment.new :name => "some_environment"
    assert environment.save!

    get :edit, {:id => environment.name}, set_session_user
    assert_response :success
  end

  test "should update environment" do
    environment = Environment.new :name => "some_environment"
    assert environment.save!

    put :update, { :commit => "Update", :id => environment.name, :environment => {:name => "other_environment"} }, set_session_user
    env = Environment.find(environment)
    assert env.name == "other_environment"

    assert_redirected_to environments_path
  end

  test "should update environment using json" do
    environment = Environment.new :name => "some_environment"
    assert environment.save!

    put :update, { :format => "json", :commit => "Update", :id => environment.name, :environment => {:name => "other_environment"} }, set_session_user
    env = ActiveSupport::JSON.decode(@response.body)
    assert env["environment"]["name"] = "other_environment"
    env = Environment.find(environment)
    assert env.name == "other_environment"
    assert_response :ok
  end


  test "should destroy environment" do
    environment = Environment.new :name => "some_environment"
    assert environment.save!

    assert_difference('Environment.count', -1) do
      delete :destroy, {:id => environment.name}, set_session_user
    end

    assert_redirected_to environments_path
  end

  test "should destroy environment using json" do
    environment = Environment.new :name => "some_environment"
    assert environment.save!

    assert_difference('Environment.count', -1) do
      delete :destroy, {:format => "json", :id => environment.name}, set_session_user
    end
    env = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
  end

  def setup_import_classes
    Puppetclass.delete_all
    Environment.delete_all
    @request.env["HTTP_REFERER"] = environments_url
    # This is the database status
    # and should result in a db_tree of {"env1" => ["a", "b", "c"], "env2" => ["a", "b", "c"]}
    as_admin do
      ["a", "b", "c"].each  {|name| Puppetclass.create :name => name}
      for name in ["env1", "env2"] do
        e = Environment.create!(:name => name)
        e.puppetclasses += [Puppetclass.find_by_name("a"), Puppetclass.find_by_name("b"), Puppetclass.find_by_name("c")]
      end
    end
    # This is the on-disk status
    # and should result in a disk_tree of {"env1" => ["a", "b", "c"],"env2" => ["a", "b", "c"]}
    envs = HashWithIndifferentAccess.new(:env1 => %w{a b c}, :env2 => %w{a b c})
    Environment.expects(:puppetEnvs).returns(envs).at_least_once
  end

  test "should handle disk environment containing additional classes" do
    setup_import_classes
    Environment.find_by_name("env1").puppetclasses.delete(Puppetclass.find_by_name("a"))
#    db_tree   of {"env1" => ["b", "c"],     "env2" => ["a", "b", "c"]}
#    disk_tree of {"env1" => ["a", "b", "c"],"env2" => ["a", "b", "c"]}
    get :import_environments, {}, set_session_user
    assert_template "puppetclasses_or_envs_changed"
    assert_select 'input#changed_new_env1[value*="a"]'
    post :obsolete_and_new,
      {"changed" =>
        {"new" =>
          {"env1" => '["a"]'}
        }
      }, set_session_user
    assert_redirected_to environments_url
    assert flash[:notice] = "Successfully updated environments and puppetclasses from the on-disk puppet installation"
    assert Environment.find_by_name("env1").puppetclasses.map(&:name).sort == ["a", "b", "c"]
  end
  test "should handle disk environment containing less classes" do
    setup_import_classes
    as_admin {Puppetclass.create(:name => "d")}
    Environment.find_by_name("env1").puppetclasses << Puppetclass.find_by_name("d")
    #db_tree   of {"env1" => ["a", "b", "c", "d"], "env2" => ["a", "b", "c"]}
    #disk_tree of {"env1" => ["a", "b", "c"],      "env2" => ["a", "b", "c"]}
    get :import_environments, {}, set_session_user
    assert_template "puppetclasses_or_envs_changed"
    assert_select 'input#changed_obsolete_env1[value*="d"]'
    post :obsolete_and_new,
      {"changed" =>
        {"obsolete" =>
          {"env1" => '["d"]'}
        }
      }, set_session_user
    assert_redirected_to environments_url
    assert flash[:notice] = "Succcessfully updated environments and puppetclasses from the on-disk puppet installation"
    envs = Environment.find_by_name("env1").puppetclasses.map(&:name).sort
    assert envs == ["a", "b", "c"]
  end
  test "should handle disk environment containing less environments" do
    setup_import_classes
    as_admin {Environment.create(:name => "env3")}
    #db_tree   of {"env1" => ["a", "b", "c"], "env2" => ["a", "b", "c"], "env3" => []}
    #disk_tree of {"env1" => ["a", "b", "c"], "env2" => ["a", "b", "c"]}
    get :import_environments, {}, set_session_user
    assert_template "puppetclasses_or_envs_changed"
    assert_select 'input#changed_obsolete_env3'
    post :obsolete_and_new,
      {"changed" =>
        {"obsolete" =>
          {"env3" => '[]'}
        }
      }, set_session_user
    assert_redirected_to environments_url
    assert flash[:notice] = "Successfully updated environments and puppetclasses from the on-disk puppet installation"
    assert Environment.find_by_name("env3").puppetclasses.map(&:name).sort == []
  end

  test "should fail to remove active environments" do
    setup_import_classes
    as_admin do
      host = Host.first
      host.environment = Environment.find_by_name("env1")
      host.save!
      assert host.errors.empty?
      assert Environment.find_by_name("env1").hosts.count > 0
    end
    get :import_environments, {}, set_session_user # We need this to stop failures about number of calls. It is not really part of the test.
    # assert_template "puppetclasses_or_envs_changed". This assertion will fail. And it should fail. See above.
    post :obsolete_and_new,
      {"changed"=>
        {"obsolete" =>
          {"env1"  => '["a","b","c","_destroy_"]'}
        }
      }, set_session_user
    assert Environment.find_by_name("env1").hosts.count > 0
    assert flash[:error] =~ /^Failed to update the environments and puppetclasses from the on-disk puppet installation/
    assert Environment.find_by_name("env1")
  end

  test "should obey config/ignored_environments.yml" do
    @request.env["HTTP_REFERER"] = environments_url
    setup_import_classes
    as_admin do
      Environment.create :name => "env3"
      Environment.delete_all(:name => "env1")
    end
    #db_tree   of {                         , "env2" => ["a", "b", "c"], "env3" => []}
    #disk_tree of {"env1" => ["a", "b", "c"], "env2" => ["a", "b", "c"]}

    FileUtils.mv Rails.root.to_s + "/config/ignored_environments.yml", Rails.root.to_s + "/config/ignored_environments.yml.test_bak" if File.exist? Rails.root.to_s + "/config/ignored_environments.yml"
    FileUtils.cp Rails.root.to_s + "/test/functional/ignored_environments.yml", Rails.root.to_s + "/config/ignored_environments.yml"
    get :import_environments, {}, set_session_user
    FileUtils.rm_f Rails.root.to_s + "/config/ignored_environments.yml"
    FileUtils.mv Rails.root.to_s + "/config/ignored_environments.yml.test_bak", Rails.root.to_s + "/config/ignored_environments.yml" if File.exist? Rails.root.to_s + "/config/ignored_environments.yml.test_bak"

    assert flash[:notice] == "No changes to your environments detected"
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit an environment' do
    setup_user
    get :edit, {:id => environments(:production).name}, set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing environments' do
    setup_user
    get :index, {}, set_session_user
    assert_response :success
  end
end
