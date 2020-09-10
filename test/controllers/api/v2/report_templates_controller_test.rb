require 'test_helper'

class Api::V2::ReportTemplatesControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'report_template_test', :template => 'a,b,c' }

  def setup
    @report_template = FactoryBot.create(:report_template)
  end

  let(:report_template) { FactoryBot.create(:report_template) }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:report_templates)
    report_templates = ActiveSupport::JSON.decode(@response.body)
    assert !report_templates.empty?
    template = report_templates['results'].find { |h| h['id'] == @report_template.id }
    assert_equal @report_template.name, template['name']
  end

  test "should show individual record" do
    get :show, params: { :id => @report_template.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    assert_equal @report_template['template'], show_response['template']
  end

  test "should create report_template" do
    assert_difference('ReportTemplate.unscoped.count') do
      post :create, params: { :report_template => valid_attrs }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert response.key?('template')
    assert_equal response['name'], valid_attrs[:name]
    assert_equal response['template'], valid_attrs[:template]
  end

  test "create with template length" do
    valid_params = valid_attrs.merge(:template => RFauxFactory.gen_alpha(5000))
    assert_difference('ReportTemplate.unscoped.count') do
      post :create, params: { :report_template => valid_params }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('template')
    assert_equal response['template'], valid_params[:template]
  end

  test "create with one character name" do
    valid_params = valid_attrs.merge(:name => RFauxFactory.gen_alpha(1))
    assert_difference('ReportTemplate.unscoped.count') do
      post :create, params: { :report_template => valid_params }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert_equal response['name'], valid_params[:name]
  end

  test "should create report_template with organization" do
    organization_id = Organization.first.id
    assert_difference('ReportTemplate.unscoped.count') do
      post :create, params: { :report_template => valid_attrs.merge(:organization_ids => [organization_id]) }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert response.key?('organizations')
    organization_ids = response['organizations'].map { |org| org['id'] }
    assert_equal organization_ids.length, 1
    assert_include organization_ids, organization_id
  end

  test "should update name" do
    new_name = 'new report_template name'
    put :update, params: { :id => @report_template.id, :report_template => { :name => new_name } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert_equal response['name'], new_name
  end

  test "should update template" do
    new_template = 'new report_template template'
    put :update, params: { :id => @report_template.id, :report_template => { :template => new_template } }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('template')
    assert_equal response['template'], new_template
  end

  test "should not create with invalid name" do
    assert_difference('ReportTemplate.unscoped.count', 0) do
      post :create, params: { :report_template => valid_attrs.merge(:name => '') }
    end
    assert_response :unprocessable_entity
  end

  test "should not create with invalid template" do
    assert_difference('ReportTemplate.unscoped.count', 0) do
      post :create, params: { :report_template => valid_attrs.merge(:template => '') }
    end
    assert_response :unprocessable_entity
  end

  test "should not update with invalid name" do
    put :update, params: { :id => @report_template.id, :report_template => { :name => ''} }
    assert_response :unprocessable_entity
  end

  test "should not update with invalid template" do
    put :update, params: { :id => @report_template.id, :report_template => { :template => ''} }
    assert_response :unprocessable_entity
  end

  test "search report_template" do
    get :index, params: { :search => @report_template.name, :format => 'json' }
    assert_response :success, "search report_template name: '#{@report_template.name}' failed with code: #{@response.code}"
    response = JSON.parse(@response.body)
    assert_equal response['results'].length, 1
    assert_equal response['results'][0]['id'], @report_template.id
  end

  test "search report_template by name and organization" do
    org = Organization.first
    @report_template.organizations = [org]
    assert @report_template.save
    get :index, params: {:search => @report_template.name, :organization_id => org.id, :format => 'json' }
    assert_response :success, "search report_template by name and organization failed with code: #{@response.code}"
    response = JSON.parse(@response.body)
    assert_equal response['results'].length, 1
    assert_equal response['results'][0]['id'], @report_template.id
  end

  test "should created report_template with unwrapped 'template'" do
    assert_difference('ReportTemplate.unscoped.count') do
      post :create, params: valid_attrs
    end
    assert_response :created
  end

  test "should update report_template" do
    put :update, params: { :id => @report_template.to_param, :report_template => valid_attrs }
    assert_response :success
  end

  test "should destroy report_template" do
    assert_difference('ReportTemplate.unscoped.count', -1) do
      delete :destroy, params: { :id => @report_template.to_param }
    end
    assert_response :success
  end

  test "should add audit comment" do
    ReportTemplate.auditing_enabled = true
    ReportTemplate.any_instance.stubs(:valid?).returns(true)
    report_template = FactoryBot.create(:report_template)
    put :update, params: { :id => report_template.to_param,
                           :report_template => { :audit_comment => "aha", :template => "tmp" } }
    assert_response :success
    assert_equal "aha", report_template.audits.last.comment
  end

  test 'should clone template' do
    original_report_template = FactoryBot.create(:report_template)
    post :clone, params: { :id => original_report_template.to_param,
                           :report_template => {:name => 'MyClone'} }
    assert_response :success
    template = ActiveSupport::JSON.decode(@response.body)
    assert_equal(template['name'], 'MyClone')
    assert_equal(template['template'], original_report_template.template)
    refute_equal(template['id'], original_report_template.id)
  end

  test 'export should export the erb of the template' do
    get :export, params: { :id => report_template.to_param }
    assert_response :success
    assert_equal 'text/plain', response.media_type
    assert_equal report_template.to_erb, response.body
  end

  test 'clone name should not be blank' do
    post :clone, params: { :id => FactoryBot.create(:report_template).to_param,
                           :report_template => {:name => ''} }
    assert_response :unprocessable_entity
  end

  test "should import report template" do
    report_template = FactoryBot.create(:report_template, :template => 'a')
    post :import, params: { :report_template => { :name => report_template.name, :template => 'b'} }
    assert_response :success
    assert_equal 'b', ReportTemplate.unscoped.find_by_name(report_template.name).template
  end

  describe '#generate' do
    it "should generate report" do
      report_template = FactoryBot.create(:report_template, :template => '<%= 1 + 1 %>')
      post :generate, params: { id: report_template.id }
      assert_response :success
      assert_equal '2', response.body
    end

    it "should allow generating reports with headers even if data is empty" do
      report_template = FactoryBot.create(:report_template, :template => '<%= report_headers(:a); report_render %>')
      post :generate, params: { id: report_template.id, report_format: 'csv' }
      assert_response :success
      assert_equal "a\n", response.body
    end

    it "should generate report in csv format" do
      report_template = FactoryBot.create(:report_template, :template => '<%= report_row(a: 1); report_row(a: 2); report_render %>')
      post :generate, params: { id: report_template.id, report_format: 'csv' }
      assert_response :success
      assert_equal 'text/csv', response.media_type
      assert_equal "a\n1\n2\n", response.body
    end

    it "should generate report in text format which fallbacks to csv if report_render is used" do
      report_template = FactoryBot.create(:report_template, :template => '<%= report_row(a: 1); report_row(a: 2); report_render %>')
      post :generate, params: { id: report_template.id, report_format: 'txt' }
      assert_response :success
      assert_equal 'text/plain', response.media_type
      assert_equal "a\n1\n2\n", response.body
    end

    it "should generate report in yaml format" do
      report_template = FactoryBot.create(:report_template, :template => '<%= report_row(a: 1); report_row(a: 2); report_render %>')
      post :generate, params: { id: report_template.id, report_format: 'yaml' }
      assert_response :success
      assert_equal 'text/yaml', response.media_type
      assert_equal "---\n- a: 1\n- a: 2\n", response.body
    end

    it "should generate report in json format" do
      report_template = FactoryBot.create(:report_template, :template => '<%= report_row(a: 1); report_row(a: 2); report_render %>')
      post :generate, params: { id: report_template.id, report_format: 'json' }
      assert_response :success
      assert_equal 'application/json', response.media_type
      data = nil
      assert_nothing_raised do
        data = JSON.parse response.body
      end
      assert_equal 1, data[0]['a']
      assert_equal 2, data[1]['a']
    end

    it "should generate report in html format, with data escaping" do
      report_template = FactoryBot.create(:report_template, :template => '<%= report_row("<b>" => 1); report_row("<b>" => "<br>"); report_render %>')
      post :generate, params: { id: report_template.id, report_format: 'html' }
      assert_response :success
      assert_equal 'text/html', response.media_type
      assert_includes response.body, "<th>&lt;b&gt;</th>"
      assert_includes response.body, "<td>1</td>"
      assert_includes response.body, "<td>&lt;br&gt;</td>"
    end

    it "should generate report with optional params without value" do
      report_template = FactoryBot.create(:report_template, :template => '<%= 1 + 1 %> <%= input("hello") %>')
      input = FactoryBot.create(:template_input, :name => 'hello')
      report_template.template_inputs = [input]
      post :generate, params: { id: report_template.id }
      assert_response :success
      assert_equal '2 ', response.body
    end

    it "should fail with required params without value" do
      report_template = FactoryBot.create(:report_template, :template => '<%= 1 + 1 %> <%= input("hello") %>')
      input = FactoryBot.create(:template_input, :name => 'hello', :required => true)
      report_template.template_inputs = [input]
      post :generate, params: { id: report_template.id }
      assert_response :unprocessable_entity
    end

    it "should generate report with optional params with value" do
      report_template = FactoryBot.create(:report_template, :template => '<%= 1 + 1 %> <%= input("hello") %>')
      input = FactoryBot.create(:template_input, :name => 'hello', :required => true)
      report_template.template_inputs = [input]
      post :generate, params: { id: report_template.id, input_values: { hello: 'ohai' } }
      assert_response :success
      assert_equal '2 ohai', response.body
    end

    it "should generate report with in organization scope" do
      organization = Organization.first
      location = Location.first
      report_template = FactoryBot.create(:report_template, :template => '<%= 1 + 1 %>', :organization_ids => [organization.id], :location_ids => [location.id])

      setup_user('generate', 'report_templates')
      setup_user('view', 'organizations')
      setup_user('view', 'locations')
      users(:one).organizations << organization

      post :generate, params: { id: report_template.id, organization_id: organization.id }, session: set_session_user(:one)
      assert_response :success
      assert_equal '2', response.body
    end
  end

  describe '#schedule_report' do
    let(:job) { OpenStruct.new('provider_job_id' => 'JOB-UNIQUE-IDENTIFIER') }
    def expect_job_enque_with(input_values, mail_to: nil, delay_to: nil, format: nil)
      composer_params = {
        'template_id' => report_template.id.to_s,
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

    it "schedule report and returns data_url" do
      expect_job_enque_with({})
      ReportComposer::ApiParams.any_instance.stubs('convert_input_names_to_ids').returns({})
      post :schedule_report, params: { :id => report_template.id }
      assert_response :success
      assert_equal 'application/json', response.media_type
      assert_match /JOB-UNIQUE-IDENTIFIER/, JSON.parse(response.body)['data_url']
    end

    it "schedule report with parameters" do
      input_values = { '1' => { 'value' => 'bar' } }
      expect_job_enque_with(input_values)
      ReportComposer::ApiParams.any_instance.expects('convert_input_names_to_ids')
                    .with(report_template.id.to_s, { 'foo' => 'bar' })
                    .returns(input_values)
      post :schedule_report, params: { :id => report_template.id, :input_values => { 'foo' => 'bar' } }
      assert_response :success
      assert_equal 'application/json', response.media_type
      assert_match /JOB-UNIQUE-IDENTIFIER/, JSON.parse(response.body)['data_url']
    end

    it "schedule report delivery by e-mail" do
      expect_job_enque_with({}, mail_to: 'this@email.cz')
      ReportComposer::ApiParams.any_instance.stubs('convert_input_names_to_ids').returns({})
      post :schedule_report, params: { :id => report_template.id, mail_to: 'this@email.cz' }
      assert_response :success
      assert_equal 'application/json', response.media_type
      assert_match /JOB-UNIQUE-IDENTIFIER/, JSON.parse(response.body)['job_id']
      refute JSON.parse(response.body).has_key?('data_url')
    end

    it "schedule report in specific format" do
      expect_job_enque_with({}, format: 'csv')
      ReportComposer::ApiParams.any_instance.stubs('convert_input_names_to_ids').returns({})
      post :schedule_report, params: { :id => report_template.id, report_format: 'csv' }
      assert_response :success
      assert_equal 'application/json', response.media_type
      assert_match /JOB-UNIQUE-IDENTIFIER/, JSON.parse(response.body)['job_id']
    end

    it 'schedule delayed report' do
      delay_to = Time.now + 2.hours
      expect_job_enque_with({}, delay_to: delay_to)
      ReportComposer::ApiParams.any_instance.stubs('convert_input_names_to_ids').returns({})
      post :schedule_report, params: { :id => report_template.id, generate_at: delay_to }
      assert_response :success
      assert_equal 'application/json', response.media_type
      assert_match /JOB-UNIQUE-IDENTIFIER/, JSON.parse(response.body)['job_id']
      assert_match /JOB-UNIQUE-IDENTIFIER/, JSON.parse(response.body)['data_url']
    end
  end

  describe '#report_data' do
    let(:plan) { OpenStruct.new('id' => 'JOBID', 'progress' => 1.0, 'failure?' => false) }

    before do
      ReportComposer.any_instance.stubs(:load_report_template).returns(report_template)
    end

    def stub_plan(opts = {})
      opts.keys.each { |k| plan.send("#{k}=", opts[k]) }
      @controller.expects(:load_dynflow_plan).with('JOBID').returns(plan)
    end

    def stub_plan_arguments(gzip: false, user_id: User.current.id, mail_to: nil)
      composer_params = { 'template_id' => report_template.id, 'input_values' => nil, 'gzip' => gzip, 'send_mail' => !!mail_to, 'mail_to' => mail_to }
      @controller.stubs(:plan_arguments).returns([composer_params, { 'user_id' => user_id }])
    end

    describe 'failures' do
      it 'returns no_content if not ready' do
        stub_plan('progress' => 0.0)
        @controller.expects(:plan_arguments).never
        get :report_data, params: { id: report_template.id, job_id: 'JOBID' }
        assert_response :no_content
      end

      it 'fails if underlying job failed ' do
        stub_plan('failure?' => true)
        @controller.expects(:plan_arguments).never
        get :report_data, params: { id: report_template.id, job_id: 'JOBID' }
        assert_response :unprocessable_entity
      end

      it 'fails if job can not be found' do
        @controller.expects(:load_dynflow_plan).with('JOBID').returns(nil)
        get :report_data, params: { id: report_template.id, job_id: 'JOBID' }
        assert_response :not_found
      end

      it 'forbid another user to access the data' do
        stub_plan_arguments(user_id: User.current.id + 1) # another user_id
        User.current.stubs('admin?').returns(false)

        get :report_data, params: { id: report_template.id, job_id: 'JOBID' }
        assert_response :forbidden
      end
    end

    describe 'rendering' do
      before { stub_plan }

      it 'return stored_content if job done' do
        stub_plan_arguments
        StoredValue.expects('read').with('JOBID').returns('plain response')

        get :report_data, params: { id: report_template.id, job_id: 'JOBID' }
        assert_response :success
        assert_equal 'text/plain', response.media_type
        assert_equal 'plain response', response.body
      end

      it 'return gziped stored_content if job done and has gzip param' do
        stub_plan_arguments(gzip: true)
        compressed_value = ActiveSupport::Gzip.compress('plain response')
        StoredValue.expects('read').with('JOBID').returns(compressed_value)

        get :report_data, params: { id: report_template.id, job_id: 'JOBID' }
        assert_response :success
        assert_equal 'application/gzip', response.media_type
        assert_equal compressed_value, response.body
      end
    end
  end
end
