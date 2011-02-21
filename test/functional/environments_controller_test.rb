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

  test "should update environments via obsolete_and_new" do
    @request.env["HTTP_REFERER"] = environments_url
    as_admin do
      ["tester", "muc"].each {|name| Environment.create :name => name}
      ["a", "b", "c"].each   {|name| Puppetclass.create :name => name}
    end
    Environment.expects(:puppetEnvs).returns(:tester                 => "/etc/puppet/env/muc",
                                             :muc                 => "/etc/puppet/env/muc",
                                             :dog                 => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites"
                                            ).at_least_once
    Puppetclass.expects(:scanForClasses).returns(["a", "b", "c"]).at_least_once
    post :obsolete_and_new, { "changed"=>{
                                    "obsolete" => {"environments" => ["tester"] },
                                    "new"      => {"environments" => ["dog"   ] }
                            }}, set_session_user
    assert flash[:notice] = "Succcessfully updated environments and puppetclasses from the on-disk puppet installation"
    assert_nil Environment.find_by_name("tester")
    assert Environment.find_by_name("dog")
    assert Environment.find_by_name("dog").puppetclasses.map(&:name).sort == ["a", "b", "c"]
  end

  test "should update puppetclasses via obsolete_and_new" do
    @request.env["HTTP_REFERER"] = environments_url
    as_admin do
      ["tester", "base"].each {|name| Puppetclass.create :name => name}
      ["muc", "dog"].each {|name| Environment.create :name => name}
    end
    Environment.expects(:puppetEnvs).returns(:muc                 => "/etc/puppet/env/muc",
                                             :global_puppetmaster => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites",
                                             :dog                 => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites"
                                            ).at_least_once
    Puppetclass.expects(:scanForClasses).returns(["base", "cat", "tester"]).at_least_once
    post :obsolete_and_new, { "changed"=>{
                                    "obsolete" => {"puppetclasses" => ["tester"]},
                                    "new"      => {"puppetclasses" => ["cat"]   }
                             }}, set_session_user
    assert flash[:notice] = "Succcessfully updated environments and puppetclasses from the on-disk puppet installation"
    assert_nil Puppetclass.find_by_name("tester")
    assert Puppetclass.find_by_name("cat")
    assert Environment.find_by_name("muc").puppetclasses == [Puppetclass.find_by_name("base"), Puppetclass.find_by_name("cat")]
    assert Environment.find_by_name("dog").puppetclasses == [Puppetclass.find_by_name("base"), Puppetclass.find_by_name("cat")]
    assert Environment.find_by_name("global_puppetmaster").puppetclasses == [Puppetclass.find_by_name("base"), Puppetclass.find_by_name("cat")]
  end

  test "should fail to remove active environments" do
    @request.env["HTTP_REFERER"] = environments_url
    Environment.expects(:puppetEnvs).returns(:dummy               => "/etc/puppet/env/muc",
                                             :global_puppetmaster => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites"
                                            ).at_least_once
    Puppetclass.expects(:scanForClasses).returns(["a", "b", "c"]).at_least_once
    host = hosts(:myfullhost)
    as_admin do
      host.environment = Environment.find_or_create_by_name("dummy")
      host.valid?
      puts host.errors.full_messages
      assert host.save
    end
    assert_equal Host.find_by_name("myfullname.mydomain.net").environment, Environment.find_by_name("dummy")
    post :obsolete_and_new, { "changed"=>{
                                    "new"      => {"puppetclasses" => ["a", "b", "c"]},
                                    "obsolete" => {"environments"  => ["dummy"]}
                             }}, set_session_user
    assert flash[:error] =~ /^Failed to update the environments and puppetclasses from the on-disk puppet installation/
    assert Environment.find_by_name("dummy")
  end

  test "should fail to remove active puppetclasses" do
    @request.env["HTTP_REFERER"] = environments_url
    Environment.expects(:puppetEnvs).returns(:production          => "/etc/puppet/env/muc",
                                             :global_puppetmaster => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites"
                                            ).at_least_once
    host = hosts(:myfullhost)
    host.puppetclasses = [Puppetclass.find_by_name("base")]
    host.environment = Environment.find_by_name("production")
    assert host.save
    assert Host.find_by_name("myfullname.mydomain.net").puppetclasses == [Puppetclass.find_by_name("base")]
    post :obsolete_and_new, { "changed"=>{
                                    "obsolete" => {"puppetclasses" => ["base"]}
                             }}, set_session_user
    assert flash[:error] =~ /^Failed to update the environments and puppetclasses from the on-disk puppet installation/
    assert Puppetclass.find_by_name("base")
  end

  test "should report new and obsolete classes and environments" do
    # Existing envs    are production and global_puppetmaster
    # Existing classes are base and apache
    Environment.expects(:puppetEnvs).returns(:production          => "/etc/puppet/env/muc",
                                             :dog                 => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites"
                                            ).at_least_once
    Puppetclass.expects(:scanForClasses).returns(["base", "c"]).at_least_once
    post :import_environments, {}, set_session_user
    # New envs are dog, obsolete envs are global_puppetmaster
    # New classes are c, obsolete classes are apache
    assert_response :ok
    assert_template "puppetclasses_or_envs_changed"
    assert_select "input#changed_obsolete_environments_[value=global_puppetmaster]"
    assert_select "input#changed_new_environments_[value=dog]"
    assert_select "input#changed_obsolete_puppetclasses_[value=apache]"
    assert_select "input#changed_new_puppetclasses_[value=c]"
  end

  test "should obey config/ignored_classes_and_environments.yml" do
    @request.env["HTTP_REFERER"] = environments_url
    # Existing envs    are production and global_puppetmaster
    # Existing classes are base and apache
    Environment.expects(:puppetEnvs).returns(:production          => "/etc/puppet/env/muc",
                                             :dog                 => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites"
                                            ).at_least_once
    Puppetclass.expects(:scanForClasses).returns(["base", "c"]).at_least_once

    FileUtils.cp Rails.root.to_s + "/test/functional/ignored_classes_and_environments.yml", Rails.root.to_s + "/config/ignored_classes_and_environments.yml"
    # New envs are dog, obsolete envs are global_puppetmaster
    # New classes are c, obsolete classes are apache
    post :import_environments, {}, set_session_user
    FileUtils.rm_f Rails.root.to_s + "/config/ignored_classes_and_environments.yml"

    assert_redirected_to environments_url
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit an environment' do
    setup_user
    get :edit, {:id => Environment.first.id}
    assert @response.status == '403 Forbidden'
  end

  test 'user with viewer rights should succeed in viewing environments' do
    setup_user
    get :index
    assert_response :success
  end
end
