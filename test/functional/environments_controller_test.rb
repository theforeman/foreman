require 'test_helper'

class EnvironmentsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns(:environments)
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

  test "should destroy environment" do
    environment = Environment.new :name => "some_environment"
    assert environment.save!

    assert_difference('Environment.count', -1) do
      delete :destroy, {:id => environment.name}, set_session_user
    end

    assert_redirected_to environments_path
  end

  test "should update environments via obsolete_and_new" do
    @request.env["HTTP_REFERER"] = environments_url
    Environment.create :name => "tester"
    ["a", "b", "c"].each {|name| Puppetclass.create :name => name}
    Environment.expects(:puppetEnvs).returns(:muc                 => "/etc/puppet/env/muc",
                                             :global_puppetmaster => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites",
                                             :dog                 => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites"
                                            ).at_least_once
    Puppetclass.expects(:scanForClasses).returns(["a", "b", "c"]).at_least_once
    post :obsolete_and_new, { "changed"=>{
                                    "obsolete" => {"environments" => ["tester"] },
                                    "new"      => {"environments" => ["dog"   ] }
                            }}, set_session_user
    assert flash[:foreman_notice] = "Succcessfully updated environments and puppetclasses from the on-disk puppet installation"
    assert_nil Environment.find_by_name("tester")
    assert Environment.find_by_name("dog")
    assert Environment.find_by_name("dog").puppetclasses.map(&:name).sort == ["a", "b", "c"]
  end

  test "should update puppetclasses via obsolete_and_new" do
    @request.env["HTTP_REFERER"] = environments_url
    Puppetclass.create :name => "tester"
    Environment.expects(:puppetEnvs).returns(:muc                 => "/etc/puppet/env/muc",
                                             :global_puppetmaster => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites",
                                             :dog                 => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites"
                                            ).at_least_once
    post :obsolete_and_new, { "changed"=>{
                                    "obsolete" => {"puppetclasses" => ["tester"]},
                                    "new"      => {"puppetclasses" => ["cat"]   }
                             }}, set_session_user
    assert flash[:foreman_notice] = "Succcessfully updated environments and puppetclasses from the on-disk puppet installation"
    assert_nil Puppetclass.find_by_name("tester")
    assert Puppetclass.find_by_name("cat")
  end

  test "should fail to remove active environments" do
    @request.env["HTTP_REFERER"] = environments_url
    Environment.expects(:puppetEnvs).returns(:production          => "/etc/puppet/env/muc",
                                             :global_puppetmaster => "/etc/puppet/env/global_puppetmaster:/etc/puppet/modules/sites"
                                            ).at_least_once
    host = hosts(:myfullhost)
    host.environment = Environment.find_by_name("production")
    assert host.save
    assert Host.find_by_name("myfullname.mydomain.com").environment == Environment.find_by_name("production")
    post :obsolete_and_new, { "changed"=>{
                                    "obsolete" => {"environments" => ["production"]}
                             }}, set_session_user
    assert flash[:foreman_error] =~ /^Failed to update the environments and puppetclasses from the on-disk puppet installation/
    assert Environment.find_by_name("production")
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
    assert Host.find_by_name("myfullname.mydomain.com").puppetclasses == [Puppetclass.find_by_name("base")]
    post :obsolete_and_new, { "changed"=>{
                                    "obsolete" => {"puppetclasses" => ["base"]}
                             }}, set_session_user
    assert flash[:foreman_error] =~ /^Failed to update the environments and puppetclasses from the on-disk puppet installation/
    assert Puppetclass.find_by_name("base")
  end

  test "should report new and obsolete classes and environements" do
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
end
