require 'test_helper'

class FactValuesControllerTest < ActionController::TestCase
  def fact_fixture
    Pathname.new("#{Rails.root}/test/fixtures/brslc022.facts.yaml").read
  end

  def setup
    User.current = nil
  end

  fixtures

  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_template FactValue.unconfigured? ? 'welcome' : 'index'
    assert_not_nil :fact_values
  end

  def test_create_invalid
    User.current = nil
    post :create, {:facts => fact_fixture[1..-1], :format => "yml"}, set_session_user
    assert_response :bad_request
  end

  def test_create_valid_puppet_node_facts_object
    User.current = nil
    post :create, {:facts => fact_fixture, :format => "yml"}, set_session_user
    assert_response :success
  end

  def test_create_valid_facter_yaml_output
    User.current = nil
    facts = Facter.to_hash
    assert_instance_of Hash, facts
    post :create, {:facts => facts.to_yaml, :format => "yml"}, set_session_user
    assert_response :success
  end

  test 'user with viewer rights should succeed in viewing facts' do
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
    get :index, {}, set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end

  test 'show nested fact json' do
    as_user :admin do
      get :index, {:format => "json", :fact_id => "kernelversion"}, set_session_user
    end
    factvalues =  ActiveSupport::JSON.decode(@response.body)
    assert_equal "fact = kernelversion", @request.params[:search]
    assert factvalues.is_a?(Hash)
    assert_equal [["kernelversion"]], factvalues.values.map(&:keys).uniq
    assert_response :success
  end

  test 'when ":restrict_registered_puppetmasters" is false, HTTP requests should be able to import facts' do
    Setting[:restrict_registered_puppetmasters] = false
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    post :create, {:facts => fact_fixture, :format => "yml"}
    assert_response :success
  end

  test 'hosts with a registered smart proxy on should import facts successfully' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    post :create, {:facts => fact_fixture, :format => "yml"}
    assert_response :success
  end

  test 'hosts without a registered smart proxy on should not be able to import facts' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = false

    Resolv.any_instance.stubs(:getnames).returns(['another.host'])
    post :create, {:facts => fact_fixture, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'hosts with a registered smart proxy and SSL cert should import facts successfully' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN_CN'] = 'else.where'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    post :create, {:facts => fact_fixture, :format => "yml"}
    assert_response :success
  end

  test 'hosts without a registered smart proxy but with an SSL cert should not be able to import facts' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN_CN'] = 'another.host'
    @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    post :create, {:facts => fact_fixture, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'hosts with an unverified SSL cert should not be able to import facts' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true

    @request.env['HTTPS'] = 'on'
    @request.env['SSL_CLIENT_S_DN_CN'] = 'secure.host'
    @request.env['SSL_CLIENT_VERIFY'] = 'FAILED'
    post :create, {:facts => fact_fixture, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'when "require_ssl_puppetmasters" and "require_ssl" are true, HTTP requests should not be able to import facts' do
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = true

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    post :create, {:facts => fact_fixture, :format => "yml"}
    assert_equal 403, @response.status
  end

  test 'when "require_ssl_puppetmasters" is true and "require_ssl" is false, HTTP requests should be able to import facts' do
    # since require_ssl_puppetmasters is only applicable to HTTPS connections, both should be set
    Setting[:restrict_registered_puppetmasters] = true
    Setting[:require_ssl_puppetmasters] = true
    SETTINGS[:require_ssl] = false

    Resolv.any_instance.stubs(:getnames).returns(['else.where'])
    post :create, {:facts => fact_fixture, :format => "yml"}
    assert_response :success
  end
end
