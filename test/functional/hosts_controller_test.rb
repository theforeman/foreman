require 'test_helper'

class HostsControllerTest < ActionController::TestCase
  setup :initialize_host

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
      post :create, { :commit => "Create",
        :record => {:name => "myotherfullhost",
          :mac => "aabbecddee00",
          :ip => "123.05.02.25",
          :domain => {:id => Domain.find_or_create_by_name("othercompany.com").id.to_s},
          :operatingsystem => {:id => Operatingsystem.first.id.to_s},
          :architecture => {:id => Architecture.first.id.to_s},
          :environment => {:id => Environment.first.id.to_s},
          :disk => "empty partition"
        }
      }
    end
  end

  test "should get edit" do
    get :edit, :id => @host.id
    assert_response :success
  end

  test "should update host" do
    put :update, { :commit => "Update", :id => @host.id, :record => {:disk => "ntfs"} }
    @host = Host.find_by_id(@host.id)

    assert @host.disk == "ntfs"
  end

  test "should destroy host" do
    assert_difference('Host.count', -1) do
      delete :destroy, :id => @host.id
    end
  end

  test "externalNodes should render 404 when no params are given" do
    get :externalNodes
    assert_response :missing
    assert_template :text => '404 Not Found'
  end

  test "externalNodes should render correctly when id is given" do
    get :externalNodes, :id => @host.id
    assert_response :success
    assert_template :text => @host.info.to_yaml.gsub("\n","<br>")
  end

  test "externalNodes should render correctly when name is given" do
    get :externalNodes, :name => @host.name
    assert_response :success
    assert_template :text => @host.info.to_yaml.gsub("\n","<br>")
  end

  test "externalNodes should render yml request correctly" do
    get :externalNodes, :id => @host.id, :format => "yml"
    assert_response :success
    assert_template :text => @host.info.to_yaml
  end

  test "when host is saved after setBuild, the flash should informe it" do
    mock(@host).setBuild {true}
    mock(Host).find(@host.id.to_s) {@host}
    @request.env['HTTP_REFERER'] = hosts_path

    get :setBuild, {:id => @host.id}
    assert_response :found
    assert_redirected_to hosts_path
    assert_not_nil flash[:foreman_notice]
    assert flash[:foreman_notice] == "Enabled myfullhost.company.com for installation boot away"
  end

  test "when host is not saved after setBuild, the flash should informe it" do
    @request.env['HTTP_REFERER'] = hosts_path

    get :setBuild, :id => @host.id
    assert_response :found
    assert_redirected_to hosts_path
    assert_not_nil flash[:foreman_error]
    assert flash[:foreman_error] == "Failed to enable myfullhost.company.com for installation"
  end

  test "rrdreport should print error message if host has no last_report" do
    get :rrdreport, :id => @host.id
    assert_response :success
    assert_template :text => "Sorry, no graphs for this host"
  end

  test "rrdreport should render graphics" do
    @host.last_report = Date.today
    assert @host.save!
    SETTINGS[:rrd_report_url] = "/some/url"

    get :rrdreport, :id => @host.id
    assert_response :success
    assert_template :partial => "_rrdreport"
  end

  test "report should redirect to host's last report" do
    get :report, :id => @host.id
    assert_response :found
    assert_redirected_to :controller => "reports", :action => "show", :id => @host.id
  end

  test "query in .yml format should return host.to_yml" do
    get :query, :format => "yml"
    assert_template :text => @host.to_yaml
  end

  private
  def initialize_host
    @host = Host.create :name => "myfullhost",
      :mac => "aabbecddeeff",
      :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"),
      :operatingsystem => Operatingsystem.first,
      :architecture => Architecture.first,
      :environment => Environment.first,
      :disk => "empty partition"
  end
end
