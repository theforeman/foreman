require 'test_helper'

class ReportTemplatesControllerTest < ActionController::TestCase
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  def setup
    @report_template = FactoryBot.create(:report_template, :organizations => [taxonomies(:organization1)], :locations => [taxonomies(:location1)])
  end

  test 'index' do
    get :index, session: set_session_user
    assert_template 'index'
  end

  test 'new' do
    get :new, session: set_session_user
    assert_template 'new'
  end

  test 'create_invalid' do
    ReportTemplate.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :report_template => {:name => nil} }, session: set_session_user
    assert_template 'new'
  end

  test 'create_valid' do
    ReportTemplate.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :report_template => { :name => "dummy", :template => "dummy"} }, session: set_session_user
    assert_redirected_to report_templates_url
  end

  test 'edit' do
    get :edit, params: { :id => ReportTemplate.first.id }, session: set_session_user
    assert_template 'edit'
  end

  test 'update_invalid' do
    ReportTemplate.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => ReportTemplate.first.id, :report_template => {:name => nil} }, session: set_session_user
    assert_template 'edit'
  end

  test 'update_valid' do
    ReportTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => ReportTemplate.first.id, :report_template => {:name => "UpdatedDummy", :template => "dummy_template"} }, session: set_session_user
    assert_redirected_to report_templates_url
  end

  test 'destroy' do
    report_template = ReportTemplate.first
    delete :destroy, params: { :id => report_template }, session: set_session_user
    assert_redirected_to report_templates_url
    assert !ReportTemplate.exists?(report_template.id)
  end

  test "export" do
    get :export, params: { :id => @report_template.to_param }, session: set_session_user
    assert_response :success
    assert_equal 'text/plain', response.media_type
    assert_equal @report_template.to_erb, response.body
  end

  def setup_view_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a report template' do
    setup_view_user
    get :edit, params: { :id => @report_template.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should fail to delete a report template' do
    setup_view_user
    delete :destroy, params: { :id => @report_template.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should fail to create a report template' do
    setup_view_user
    post :create, params: { :report_template => {:name => "dummy", :template => "dummy"} }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing report templates' do
    setup_view_user
    get :index, session: set_session_user
    assert_response :success
  end

  def setup_edit_user
    @user = User.find_by_login("one")
    role = FactoryBot.build(:role)
    role.add_permissions!([:view_locations, :assign_locations, :edit_locations, :view_organizations, :assign_organizations, :edit_organizations, :view_report_templates, :edit_report_templates, :destroy_report_templates, :create_report_templates])
    @user.roles = [Role.default, Role.find_by_name('Viewer'), role]
  end

  test 'user with editing rights should succeed in editing a report template' do
    setup_edit_user
    get :edit, params: { :id => @report_template.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end

  test 'user with editing rights should succeed in deleting a report template' do
    setup_edit_user
    delete :destroy, params: { :id => @report_template.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_redirected_to report_templates_url
    assert_equal "Successfully deleted #{@report_template.name}.", flash[:success]
  end

  test 'user with editing rights should succeed in creating a report template' do
    setup_edit_user
    post :create, params: { :report_template => {:name => "dummy", :template => "dummy"} }, session: set_session_user.merge(:user => users(:one).id)
    assert_redirected_to report_templates_url
    assert_equal "Successfully created dummy.", flash[:success]
  end

  test 'preview' do
    host = FactoryBot.create(:host, :managed, :operatingsystem => FactoryBot.create(:suse, :with_archs, :with_media))
    template = FactoryBot.create(:report_template)

    # works for given host
    post :preview, params: { :preview_host_id => host.id, :template => '<%= @host.name -%>', :id => template }, session: set_session_user
    assert_equal host.hostname.to_s.to_json, @response.body

    # without host specified it uses first one
    post :preview, params: { :template => '<%= 1+1 -%>', :id => template }, session: set_session_user
    assert_equal '2'.to_json, @response.body

    post :preview, params: { :template => '<%= 1+1 -%>' }, session: set_session_user
    assert_equal '2'.to_json, @response.body

    post :preview, params: { :template => '<%= 1+ -%>', :id => template }, session: set_session_user
    assert_includes @response.body, 'parse error on value'
  end

  test "generate" do
    get :generate, params: { :id => @report_template.to_param }, session: set_session_user
    assert_response :success
  end

  describe '#schedule_report' do
    let(:job) { OpenStruct.new('provider_job_id' => 'JOB-UNIQUE-IDENTIFIER') }
    def expect_job_enque_with(input_values, mail_to: nil, delay_to: nil, format: nil)
      composer_params = {
        'template_id' => @report_template.to_param,
        'input_values' => input_values,
        'gzip' => !!mail_to,
        'send_mail' => !!mail_to,
        'mail_to' => mail_to,
        'format' => format,
      }
      if delay_to
        scheduler = mock('TemplateRenderJob')
        TemplateRenderJob.expects(:set).with(has_key(:wait_until)).returns(scheduler)
      else
        scheduler = TemplateRenderJob
      end
      scheduler.expects(:perform_later).with(composer_params, user_id: User.current.id).returns(job)
    end

    it "schedule report and returns report_data_url" do
      expect_job_enque_with(nil)
      get :schedule_report, params: { :id => @report_template.to_param }, session: set_session_user
      assert_redirected_to report_data_report_template_url(@report_template, job_id: 'JOB-UNIQUE-IDENTIFIER')
    end

    it "schedule report with parameters" do
      expect_job_enque_with({ '1' => { 'value' => 'ohai' } })
      get :schedule_report, params: { :id => @report_template.to_param, :report_template_report => { :input_values => { '1' => { :value => 'ohai' } } } }, session: set_session_user
      assert_redirected_to report_data_report_template_url(@report_template, job_id: 'JOB-UNIQUE-IDENTIFIER')
    end

    it "schedule report with format" do
      expect_job_enque_with(nil, format: 'yaml')
      get :schedule_report, params: { :id => @report_template.to_param, :report_template_report => { :format => 'yaml' } }, session: set_session_user
      assert_redirected_to report_data_report_template_url(@report_template, job_id: 'JOB-UNIQUE-IDENTIFIER')
    end

    it "schedule report delivery by e-mail" do
      expect_job_enque_with(nil, mail_to: 'this@email.cz')
      get :schedule_report, params: { :id => @report_template.to_param, :report_template_report => { send_mail: '1', mail_to: 'this@email.cz' } }, session: set_session_user
      assert_redirected_to report_templates_url
    end

    it 'schedule delayed report' do
      delay_to = Date.today.to_time + 2.hours
      expect_job_enque_with(nil, delay_to: delay_to)
      get :schedule_report, params: { :id => @report_template.to_param, :report_template_report => { generate_at: delay_to } }, session: set_session_user
      assert_redirected_to report_data_report_template_url(@report_template, job_id: 'JOB-UNIQUE-IDENTIFIER')
    end
  end
end
