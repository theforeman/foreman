require 'test_helper'

class AuditTest < ActiveSupport::TestCase
  describe '.taxed_and_untaxed scope' do
    let(:user_organization) { FactoryBot.create(:organization) }
    let(:subuser_organization) { as_admin { FactoryBot.create(:organization, parent: user_organization) } }
    let(:user_organization2) { FactoryBot.create(:organization) }
    let(:ignore_organization) { FactoryBot.create(:organization, ignore_types: ['User']) }
    let(:nonuser_organization) { FactoryBot.create(:organization) }
    let(:user_location) { FactoryBot.create(:location) }
    let(:subuser_location) { FactoryBot.create(:location, parent: user_location) }
    let(:user_location2) { FactoryBot.create(:location) }
    let(:ignore_location) { FactoryBot.create(:location, ignore_types: ['User']) }
    let(:nonuser_location) { FactoryBot.create(:location) }
    let(:user) { FactoryBot.create(:user, organizations: [user_organization, user_organization2], locations: [user_location, user_location2]) }

    context 'with view only user' do
      setup do
        setup_user('view', 'audit_logs', nil, user)
        Audit.destroy_all
      end

      { model: :name, operatingsystem: :name }.each do |model, audited_attribute|
        context "with untaxed model #{model}" do
          let(:record) do
            r = FactoryBot.create(model)
            r.update(audited_attribute => 'newValue')
            r
          end
          setup { as_admin { record } }

          it "include all records of #{model}" do
            assert_include Audit.taxed_and_untaxed.pluck(:id), record.audits.first.id
          end
        end
      end

      # Test single taxed records behaviour - location_taxables and organization_taxables
      { location: 'Organization', organization: 'Location' }.each do |scope, tested_model|
        context "#{scope}_taxables only" do
          [["user_#{scope}"], ["user_#{scope}2"], ["subuser_#{scope}"], ["subuser_#{scope}", "nonuser_#{scope}"], ["ignore_#{scope}"]].each do |test_set|
            it "include #{tested_model} record audits with no current #{scope} set" do
              subject = make_subject(scope, tested_model, test_set)
              assert_include Audit.taxed_and_untaxed.pluck(:id), subjects_audis(tested_model, subject).first.id
            end
          end

          it "does not include records with non user #{scope}" do
            subject = make_subject(scope, tested_model, ["nonuser_#{scope}"])
            assert_not_include Audit.taxed_and_untaxed.pluck(:id), subjects_audis(tested_model, subject).first.id
          end

          [["user_#{scope}"], ["user_#{scope}", "nonuser_#{scope}"]].each do |test_set|
            it "include #{scope}'s #{tested_model}s if current #{scope} set" do
              subject = make_subject(scope, tested_model, test_set)
              with_current_tax(scope, "user_#{scope}") do
                assert_include Audit.taxed_and_untaxed.pluck(:id), subjects_audis(tested_model, subject).first.id
              end
            end
          end

          it "includes current #{scope} #{tested_model}s if #{scope} ignores User" do
            subject = make_subject(scope, tested_model, ["ignore_#{scope}"])
            with_current_tax(scope, "ignore_#{scope}") do
              assert_include Audit.taxed_and_untaxed.pluck(:id), subjects_audis(tested_model, subject).first.id
            end
          end

          [["user_#{scope}2"], ["user_#{scope}2", "nonuser_#{scope}"], ["ignore_#{scope}"]].each do |test_set|
            it "does not include records out of set #{scope}" do
              subject = make_subject(scope, tested_model, test_set)
              with_current_tax(scope, "user_#{scope}") do
                assert_not_include Audit.taxed_and_untaxed.pluck(:id), subjects_audis(tested_model, subject).first.id
              end
            end
          end

          private

          def make_subject(scope, tested_model, test_set)
            as_admin do
              subject = FactoryBot.create(tested_model.underscore.to_sym, scope.to_s.pluralize.to_sym => test_set.map { |l| send(l) })
              subject.update(description: "New description for #{tested_model}")
              subject
            end
          end

          def subjects_audis(tested_model, subject)
            Audit.where(auditable_id: subject.id, auditable_type: tested_model)
          end

          def with_current_tax(type, tax_record_name, &block)
            case type
            when :location
              Location.as_location(send(tax_record_name), &block)
            when :organization
              Organization.as_org(send(tax_record_name), &block)
            end
          end
        end
      end

      # Test fully taxed records behaviour
      describe 'fully_taxable Domain' do
        context 'without current taxonomies' do
          it 'includes record if belongs to both user Org and Loc' do
            subject = make_subject(['user_organization'], ['user_location'])
            assert_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
          end

          it 'includes record if belongs to users Org and Loc even if belongs to others too' do
            subject = make_subject(['user_organization', 'nonuser_organization'], ['user_location', 'nonuser_location'])
            assert_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
          end

          it 'includes record if belongs to subs of users Org and Loc' do
            subject = make_subject(['subuser_organization', 'nonuser_organization'], ['subuser_location', 'nonuser_location'])
            assert_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
          end

          it 'includes record if Org ignores User' do
            subject = make_subject(['ignore_organization', 'nonuser_organization'], ['user_location'])
            assert_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
          end

          it 'includes record if Loc ignores User' do
            subject = make_subject(['user_organization'], ['ignore_location', 'nonuser_location'])
            assert_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
          end

          it 'does not include records out of users Org and Loc' do
            subject = make_subject(['nonuser_organization'], ['nonuser_location'])
            assert_not_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
          end

          it 'does not include records out of users Org and in users Loc' do
            subject = make_subject(['nonuser_organization'], ['user_location', 'nonuser_location'])
            assert_not_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
          end

          it 'does not include records out of users Loc and in users Org' do
            subject = make_subject(['user_organization', 'nonuser_organization'], ['nonuser_location'])
            assert_not_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
          end
        end

        context 'with current taxonomy set' do
          it 'includes records if Org set to users Org' do
            subject = make_subject(['user_organization'], ['ignore_location', 'nonuser_location'])
            Taxonomy.as_taxonomy(user_organization, nil) do
              assert_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
            end
          end

          it 'does not include records if Loc not set, but record do not have User loc' do
            subject = make_subject(['user_organization'], ['nonuser_location'])
            Taxonomy.as_taxonomy(user_organization, nil) do
              assert_not_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
            end
          end

          it 'includes records if Org set to users and Loc to ignore' do
            subject = make_subject(['user_organization'], ['ignore_location', 'nonuser_location'])
            Taxonomy.as_taxonomy(user_organization, ignore_location) do
              assert_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
            end
          end

          it 'includes child records to current taxonomy' do
            subject = make_subject(['subuser_organization'], ['ignore_location'])
            Taxonomy.as_taxonomy(user_organization, ignore_location) do
              assert_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
            end
          end

          it 'does not include records with parent Taxonomy to current taxonomy' do
            skip('This doesnt work like this, even though it should')
            subuser_organization
            subject = make_subject(['user_organization'], ['user_location'])
            Taxonomy.as_taxonomy(subuser_organization, user_location) do
              assert_not_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
            end
          end

          # we are running this instead of above, because thats how it works now,
          # Points to people who can break and remove this test
          it 'includes records with parent Taxonomy to current taxonomy' do
            subuser_organization
            subject = make_subject(['user_organization'], ['user_location'])
            Taxonomy.as_taxonomy(subuser_organization, user_location) do
              assert_include Audit.taxed_and_untaxed.pluck(:id), subject.audits.first.id
            end
          end
        end

        def make_subject(org_names, loc_names)
          as_admin do
            domain = FactoryBot.create(:domain, organizations: org_names.map { |l| send(l) }, locations: loc_names.map { |l| send(l) })
            domain.update(fullname: 'New domain name')
            domain
          end
        end
      end
    end
  end

  describe 'search' do
    test 'can be found by provisioning template name' do
      template = FactoryBot.create(:provisioning_template)
      template.update :template => 'new content'
      audits = Audit.search_for "provisioning_template = #{template.name}"
      assert_not_nil audits.select { |a| a.action.to_s == 'update' && a.audited_changes['template'].last == 'new content' }
    end

    test 'does not find any unrelated audits' do
      template = FactoryBot.create(:provisioning_template)
      template.update :template => 'new content'
      audits = Audit.search_for "provisioning_template = does not exist"
      assert_empty audits
    end

    test 'can be found by partition table name' do
      template = FactoryBot.create(:ptable, :os_family => nil)
      template.update :template => 'new content'
      audits = Audit.search_for "partition_table = #{template.name}"
      assert_not_nil audits.select { |a| a.action.to_s == 'update' && a.audited_changes['template'].last == 'new content' }
    end

    test 'can be found by setting name' do
      FactoryBot.create(:setting, name: 'test_audit_setting')
      Setting.find_by(name: 'test_audit_setting').update(value: 'New value')
      audits = Audit.search_for('setting = test_audit_setting')
      assert_not_nil audits.select { |a| a.action.to_s == 'update' && a.audited_changes['auditable_name'] == 'test_audit_setting' }
    end

    context 'nics' do
      let(:host) { FactoryBot.create(:host, :managed, :with_auditing) }
      let(:nic) { host.primary_interface }

      test 'can be found by ip' do
        nic
        audit = Audit.search_for("interface_ip = #{nic.ip}").first
        assert_equal nic.type, audit.auditable_type
        assert_equal 'create', audit.action
      end

      test 'can be found by name' do
        nic
        audit = Audit.search_for("interface_fqdn = #{nic.name}").first
        assert_equal nic.type, audit.auditable_type
        assert_equal 'create', audit.action
      end

      test 'can be found by mac' do
        nic
        audit = Audit.search_for("interface_mac = #{nic.mac}").first
        assert_equal nic.type, audit.auditable_type
        assert_equal 'create', audit.action
      end
    end
  end
end
