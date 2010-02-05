require 'test_helper'

class HostsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create new host" do
    assert_difference 'Host.count' do
      post :create, { :commit => "Create", :record => {:name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => {:id => Domain.find_or_create_by_name("company.com").id.to_s}, :operatingsystem => {:id => Operatingsystem.first.id.to_s}, :architecture => {:id => Architecture.first.id.to_s}, :environment => {:id => Environment.first.id.to_s}, :disk => "empty partition"} }
    end
  end

  test "should get edit" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    get :edit, :id => host.id
    assert_response :success
  end

  test "should update host" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    put :update, { :commit => "Update", :id => host.id, :record => {:disk => "ntfs"} }
    host2 = Host.find_by_id(host.id)

    assert host2.disk == "ntfs"
  end

  test "should destroy architecture" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    assert_difference('Host.count', -1) do
      delete :destroy, :id => host.id
    end
  end

  test "externalNodes should render 404 when no params are given" do
    get :externalNodes
    assert_response :missing
    assert_template :text => '404 Not Found'
  end

  test "externalNodes should render correctly when id is given" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    get :externalNodes, :id => host.id
    assert_response :success
    assert_template :text => host.info.to_yaml.gsub("\n","<br>")
  end

  test "externalNodes should render correctly when name is given" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    get :externalNodes, :name => host.name
    assert_response :success
    assert_template :text => host.info.to_yaml.gsub("\n","<br>")
  end

  test "externalNodes should render yml request correctly" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    get :externalNodes, :id => host.id, :format => "yml"
    assert_response :success
    assert_template :text => host.info.to_yaml
  end

  test "when host is saved after setBuild, the flash should informe it" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"
    stub(host).setBuild {true}
    @request.env['HTTP_REFERER'] = hosts_path

    get :setBuild, :id => host.id
    assert_response :found
    assert_redirected_to hosts_path
    # TODO: test flash content according to host.setBuild
  end

  test "rrdreport should print error message if host has no last_report" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    get :rrdreport, :id => host.id
    assert_response :success
    assert_template :text => "Sorry, no graphs for this host"
  end

  test "rrdreport should render graphics" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition",
      :last_report => Date.today
    SETTINGS[:rrd_report_url] = "/some/url"

    get :rrdreport, :id => host.id
    assert_response :success
    assert_template :partial => "_rrdreport"
  end

  test "report should redirect to host's last report" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition",
      :last_report => Date.today

    get :report, :id => host.id
    assert_response :found
    assert_redirected_to :controller => "reports", :action => "show", :id => host.id
  end

  test "query in .yml format should return host.to_yml" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    get :query, :format => "yml"
    assert_template :text => host.to_yaml
  end
end
