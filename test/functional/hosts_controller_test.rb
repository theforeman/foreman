require 'test_helper'

class HostsControllerTest < ActionController::TestCase
  setup :initialize_host

  def test_show
    get :show, {:id => Host.first.name}, set_session_user
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
    get :edit, {:id => @host.name}, set_session_user
    assert_response :success
    assert_template 'edit'
  end

  test "should update host" do
    put :update, { :commit => "Update", :id => @host.name, :host => {:disk => "ntfs"} }, set_session_user
    @host = Host.find(@host)
    assert_equal @host.disk, "ntfs"
  end

  def test_update_invalid
    Host.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Host.first.name}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Host.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Host.first.name}, set_session_user
    assert_redirected_to host_url(assigns(:host))
  end

  test "should destroy host" do
    assert_difference('Host.count', -1) do
      delete :destroy, {:id => @host.name}, set_session_user
    end
    assert_redirected_to hosts_url
  end

  test "externalNodes should render 404 when no params are given" do
    get :externalNodes, {}, set_session_user
    assert_response :missing
    assert_template :text => '404 Not Found'
  end

  test "externalNodes should render correctly when format text/html is given" do
    get :externalNodes, {:id => @host.name}, set_session_user
    assert_response :success
    assert_template :text => @host.info.to_yaml.gsub("\n","<br/>")
  end

  test "externalNodes should render yml request correctly" do
    get :externalNodes, {:id => @host.name, :format => "yml"}, set_session_user
    assert_response :success
    assert_template :text => @host.info.to_yaml
  end

  test "when host is saved after setBuild, the flash should inform it" do
    mock(@host).setBuild {true}
    mock(Host).find_by_name(@host.name) {@host}
    @request.env['HTTP_REFERER'] = hosts_path

    get :setBuild, {:id => @host.name}, set_session_user
    assert_response :found
    assert_redirected_to hosts_path
    assert_not_nil flash[:foreman_notice]
    assert flash[:foreman_notice] == "Enabled myfullhost.company.com for rebuild on next boot"
  end

  test "when host is not saved after setBuild, the flash should inform it" do
    mock(@host).setBuild {false}
    mock(Host).find_by_name(@host.name) {@host}
    @request.env['HTTP_REFERER'] = hosts_path

    get :setBuild, {:id => @host.name}, set_session_user
    assert_response :found
    assert_redirected_to hosts_path
    assert_not_nil flash[:foreman_error]
    assert flash[:foreman_error] == "Failed to enable myfullhost.company.com for installation"
  end

  test "report should redirect to host's last report" do
    get :report, {:id => @host.name}, set_session_user
    assert_response :found
    assert_redirected_to :controller => "reports", :action => "show", :id => Report.maximum(:id, :conditions => {:host_id => @host})
  end

  test "query in .yml format should return host.to_yml" do
    get :query, {:format => "yml"}, set_session_user
    assert_template :text => @host.to_yaml
  end

  def test_clone
    get :clone, {:id => Host.first.name}, set_session_user
    assert_template 'new'
  end

  context "multiple assignments" do
    setup do
      @host1 = hosts(:otherfullhost)
      @host2 = hosts(:anotherfullhost)
    end

    context "with update environments" do
      should "change environments" do
        assert @host1.environment == environments(:production)
        assert @host2.environment == environments(:production)
        post :update_multiple_environment,
             {:environment => { :id => environments(:global_puppetmaster).id}},
             {:selected => [@host1.id, @host2.id], :user => User.first.id}
        assert Host.find(@host1.id).environment == environments(:global_puppetmaster)
        assert Host.find(@host2.id).environment == environments(:global_puppetmaster)
      end
    end
    context "with update parameters" do
      should "change parameters" do
        @host1.host_parameters = [HostParameter.create(:name => "p1", :value => "yo")]
        @host2.host_parameters = [HostParameter.create(:name => "p1", :value => "hi")]
        post :update_multiple_parameters,
             {:name => { "p1" => "hello"}},
             {:selected => [@host1.id, @host2.id], :user => User.first.id}
        assert Host.find(@host1.id).host_parameters[0][:value] == "hello"
        assert Host.find(@host2.id).host_parameters[0][:value] == "hello"
      end
    end

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
