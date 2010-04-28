require 'test_helper'

class HostsControllerTest < ActionController::TestCase
  setup :initialize_host

  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Host.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Host.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Host.any_instance.stubs(:valid?).returns(true)
    post :create, :host => {:name => "test"}
    assert_redirected_to host_url(assigns(:host))
  end

  def test_edit
    get :edit, :id => Host.first
    assert_template 'edit'
  end

  def test_update_invalid
    Host.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Host.first
    assert_template 'edit'
  end

  def test_update_valid
    Host.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Host.first
    assert_redirected_to host_url(assigns(:host))
  end

  def test_destroy
    host = Host.first
    delete :destroy, :id => host
    assert_redirected_to hosts_url
    assert !Host.exists?(host.id)
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
    mock(@host).setBuild {false}
    mock(Host).find(@host.id.to_s) {@host}
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
