require 'test_helper'

class HostsControllerTest < ActionController::TestCase
  setup :initialize_host

  def test_show
    get :show, {:id => Host.first}, set_session_user
    assert_template 'show'
  end

  def test_create_invalid
    Host.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Host.any_instance.stubs(:valid?).returns(true)
    post :create, {:host => {:name => "test"}}, set_session_user
    assert_redirected_to host_url(assigns('host'))
  end

  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_template 'index'
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
    assert_template 'new'
  end

  test "should create new host" do
    assert_difference 'Host.count' do
      post :create, { :commit => "Create",
        :host => {:name => "myotherfullhost",
          :mac => "aabbecddee06",
          :ip => "123.05.04.25",
          :domain => Domain.find_or_create_by_name("othercompany.com"),
          :operatingsystem =>  Operatingsystem.first,
          :architecture => Architecture.first,
          :environment => Environment.first,
          :disk => "empty partition"
        }
      }, set_session_user
    end
    assert_redirected_to host_url(assigns['host'])
  end

  test "should get edit" do
    get :edit, {:id => @host.id}, set_session_user
    assert_response :success
    assert_template 'edit'
  end

  test "should update host" do
    put :update, { :commit => "Update", :id => @host.id, :host => {:disk => "ntfs"} }, set_session_user
    @host = Host.find_by_id(@host.id)
    assert_equal @host.disk, "ntfs"
  end

  def test_update_invalid
    Host.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Host.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Host.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Host.first}, set_session_user
    assert_redirected_to host_url(assigns(:host))
  end

  test "should destroy host" do
    assert_difference('Host.count', -1) do
      delete :destroy, {:id => @host.id}, set_session_user
    end
    assert_redirected_to hosts_url
  end

  test "externalNodes should render 404 when no params are given" do
    get :externalNodes, {}, set_session_user
    assert_response :missing
    assert_template :text => '404 Not Found'
  end

  test "externalNodes should render correctly when id is given" do
    get :externalNodes, {:id => @host.id}, set_session_user
    assert_response :success
    assert_template :text => @host.info.to_yaml.gsub("\n","<br>")
  end

  test "externalNodes should render correctly when name is given" do
    get :externalNodes, {:name => @host.name}, set_session_user
    assert_response :success
    assert_template :text => @host.info.to_yaml.gsub("\n","<br>")
  end

  test "externalNodes should render yml request correctly" do
    get :externalNodes, {:id => @host.id, :format => "yml"}, set_session_user
    assert_response :success
    assert_template :text => @host.info.to_yaml
  end

  test "when host is saved after setBuild, the flash should inform it" do
    mock(@host).setBuild {true}
    mock(Host).find(@host.id.to_s) {@host}
    @request.env['HTTP_REFERER'] = hosts_path

    get :setBuild, {:id => @host.id}, set_session_user
    assert_response :found
    assert_redirected_to hosts_path
    assert_not_nil flash[:foreman_notice]
    assert flash[:foreman_notice] == "Enabled myfullhost.company.com for rebuild on next boot"
  end

  test "when host is not saved after setBuild, the flash should inform it" do
    mock(@host).setBuild {false}
    mock(Host).find(@host.id.to_s) {@host}
    @request.env['HTTP_REFERER'] = hosts_path

    get :setBuild, {:id => @host.id}, set_session_user
    assert_response :found
    assert_redirected_to hosts_path
    assert_not_nil flash[:foreman_error]
    assert flash[:foreman_error] == "Failed to enable myfullhost.company.com for installation"
  end

  test "rrdreport should print error message if host has no last_report" do
    get :rrdreport, {:id => @host.id}, set_session_user
    assert_response :success
    assert_template :text => "Sorry, no graphs for this host"
  end

  test "rrdreport should render graphics" do
    @host.last_report = Date.today
    assert @host.save!
    SETTINGS[:rrd_report_url] = "/some/url"

    get :rrdreport, {:id => @host.id}, set_session_user
    assert_response :success
    assert_template :partial => "_rrdreport"
  end

  test "report should redirect to host's last report" do
    get :report, {:id => @host.id}, set_session_user
    assert_response :found
    assert_redirected_to :controller => "reports", :action => "show", :id => Report.maximum(:id, :conditions => {:host_id => @host})
  end

  test "query in .yml format should return host.to_yml" do
    get :query, {:format => "yml"}, set_session_user
    assert_template :text => @host.to_yaml
  end

  def test_clone
    get :clone, {:id => Host.first}, set_session_user
    assert_template 'new'
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
