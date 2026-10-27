module TemplateRevisionTest
  extend ActiveSupport::Concern

  module ClassMethods
    def template_revision_tests(factory, api: false)
      context 'revision authorization' do
        setup do
          @revision_factory = factory
          @revision_organization = FactoryBot.create(:organization)
          @revision_location = FactoryBot.create(:location)
          @revision_template, @revision_audit = revision_template_in(@revision_organization, @revision_location)
          @revision_user = users(:one)
          @revision_user.roles = []
          @revision_user.organizations = [@revision_organization]
          @revision_user.locations = [@revision_location]
          @revision_user.default_organization = @revision_organization
          @revision_user.default_location = @revision_location
          @revision_user.save!
          setup_user('view', factory.to_s.pluralize)
          # The controller's own setup may still need to create other resources.
          User.current = users(:admin)
        end

        test 'requires audit permission even for an accessible template' do
          request_revision(@revision_audit)
          assert_response :not_found
        end

        test 'returns an older revision to a non-admin with audit permission' do
          setup_user('view', 'audit_logs')
          request_revision(@revision_audit)
          assert_response :success
          assert_equal 'historical content', response.body
          assert_equal 'current content', @revision_template.reload.template
        end

        test 'returns an older revision to an administrator' do
          User.current = users(:admin)
          get :revision, params: { :version => @revision_audit.id }, session: set_session_user
          assert_response :success
          assert_equal 'historical content', response.body
        end

        [:organization, :location].each do |taxonomy|
          test "rejects an audit from another #{taxonomy} with audit permission granted" do
            setup_user('view', 'audit_logs')
            organization, location = @revision_organization, @revision_location
            as_admin do
              organization = FactoryBot.create(:organization) if taxonomy == :organization
              location = FactoryBot.create(:location) if taxonomy == :location
            end
            _, foreign_audit = revision_template_in(organization, location)

            request_revision(@revision_audit)
            assert_response :success
            request_revision(foreign_audit)
            assert_response :not_found
          end
        end

        test 'preserves search restrictions on audit permission' do
          setup_user('view', 'audit_logs', "id = #{@revision_audit.id}")
          request_revision(@revision_audit)
          assert_response :success
          request_revision(@revision_template.audits.reorder(:id).last)
          assert_response :not_found
        end

        test 'returns not found for a missing audit' do
          setup_user('view', 'audit_logs')
          get :revision, params: { :version => Audit.unscoped.maximum(:id) + 1 }, session: revision_session
          assert_response :not_found
        end

        unless api
          test 'hides history metadata and controls without audit permission' do
            setup_user('edit', factory.to_s.pluralize)
            get :edit, params: { :id => @revision_template.id }, session: revision_session
            assert_response :success
            assert_empty assigns(:history)
            assert_select '#history_tab', :count => 0
            assert_select '#history', :count => 0
            refute_includes response.body, 'private history comment'
          end

          test 'shows only history allowed by the audit permission filter' do
            setup_user('edit', factory.to_s.pluralize)
            setup_user('view', 'audit_logs', "id = #{@revision_audit.id}")
            get :edit, params: { :id => @revision_template.id }, session: revision_session
            assert_response :success
            assert_equal [@revision_audit.id], assigns(:history).map(&:id)
            assert_select '#history_tab', :count => 1
            assert_select '#history [data-version]', :count => 1
            assert_includes response.body, 'private history comment'
          end
        end
      end
    end
  end

  def revision_template_in(organization, location)
    as_admin do
      with_auditing(@revision_factory.to_s.classify.constantize) do
        template = FactoryBot.create(@revision_factory, :with_auditing,
          :organizations => [organization], :locations => [location], :template => 'initial content')
        template.update!(:template => 'historical content', :audit_comment => 'private history comment')
        audit = template.audits.reorder(:id).last
        template.update!(:template => 'current content', :audit_comment => 'current comment')
        [template, audit]
      end
    end
  end

  def revision_session
    User.current = @revision_user
    set_session_user(@revision_user).merge(
      :organization_id => @revision_organization.id, :location_id => @revision_location.id)
  end

  def request_revision(audit)
    get :revision, params: { :version => audit.id }, session: revision_session
  end
end
