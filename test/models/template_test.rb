require 'test_helper'

class TemplateTest < ActiveSupport::TestCase
  describe "generating metadata" do
    setup do
      @template = Template.new :name => 'Name of template'
    end

    test "metadata are placed in erb comment" do
      assert_match /\A<%#(\n|.)*%>/, @template.metadata
    end

    test "metadata contains name unchanged" do
      assert_match /^name: Name of template$/, @template.metadata
    end

    test "metadata contains model information" do
      assert_match /^model: Template$/, @template.metadata
    end

    test "metadata skips blank attributes" do
      @template.name = ''
      refute_match /^name:&/, @template.metadata
    end

    test "metadata does not contain dashes prefix" do
      refute_includes @template.metadata, '---'
    end
  end

  describe "stripping metadata" do
    setup do
      content = "<%#
name: basic
%>
few
lines
below"
      @template = Template.new :name => 'basic', :template => content
    end

    test "metadata are stripped from the beginning" do
      without = @template.template_without_metadata
      refute_includes without, '<%#'
    end

    test "silent metadata are stripped too" do
      @template.template.gsub('%>', '-%>')
      without = @template.template_without_metadata
      refute_includes without, '<%#'
    end

    test "metadata are stripped from the middle" do
      @template.template = "<%#\another comment\n%>\nsome\ndata\n" + @template.template
      without = @template.template_without_metadata
      refute_includes without, 'name: basic'
    end

    test "other erb comments not containing name: are preserved" do
      @template.template = "prefix\n<% another erb tag %>\nsome\ndata\n" + @template.template
      without = @template.template_without_metadata
      assert_includes without, "prefix"
      assert_includes without, "<% another erb tag %>"
      assert_includes without, "\nsome\ndata\n"
      assert_includes without, "\nfew\nlines\nbelow"
    end

    test "metadata are detected by name attribute on any comment line" do
      lines = @template.template.lines
      @template.template = [lines[0], 'another: comment', lines[1..-1]].flatten.join("\n")
      without = @template.template_without_metadata
      refute_includes without, 'name: basic'
    end
  end

  describe "#filename" do
    setup do
      @template = Template.new
    end

    test "filename adds erb suffix" do
      @template.name = 'a'
      assert_equal 'a.erb', @template.filename
    end

    test "filename replaces spaces to underscores" do
      @template.name = 'a bc d'
      assert_equal 'a_bc_d.erb', @template.filename
    end

    test "filename removes dashes" do
      @template.name = 'a-bc-d'
      assert_equal 'abcd.erb', @template.filename
    end
  end

  describe "#to_erb" do
    setup do
      content = "<%#
name: basic
%>
data"
      @template = Template.new :name => 'basic', :template => content
    end

    test "it generates fresh fresh metadata and replaces original ones" do
      @template.stub(:metadata, "METADATA\n") do
        assert_equal "METADATA\ndata", @template.to_erb
      end
    end
  end

  context "importing" do
    setup do
      @snippet_text = <<~EOS
        <%#
        kind: snippet
        name: epel
        model: ProvisioningTemplate
        snippet: true
        -%>
        rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
      EOS
      @template = Template.new
    end

    describe '.import_without_save' do
      test 'it does match existing template by name' do
        existing = FactoryBot.create(:ptable)
        assert_equal existing.id, Template.import_without_save(existing.name, @snippet_text).id
      end

      test 'it builds a new object if there is no template with such name and it initializes the name attribute' do
        template = Template.import_without_save('absolutely_new_template_snippet', @snippet_text)
        assert template.new_record?
        assert_equal 'absolutely_new_template_snippet', template.name
        assert_kind_of Template, template
        assert template.snippet
      end

      test 'it searches templates regardless of current scope, validations prevent permission exceeding' do
        existing = FactoryBot.create(:ptable, :name => 'epel', :organization_ids => [taxonomies(:organization2).id])
        in_taxonomy(taxonomies(:organization1)) do
          assert_equal existing.id, Template.import_without_save(existing.name, @snippet_text).id
        end
      end

      test 'it locks a template when lock is boolean' do
        template = Template.import_without_save('template_locked_with_bool', @snippet_text, { :lock => true })
        assert template.locked
      end

      test 'it locks a template when lock is lambda' do
        template = Template.import_without_save('template_locked_with_lambda', @snippet_text, { :lock => ->(template) { template.new_record? } })
        assert template.locked
      end
    end

    describe '.parse_metadata' do
      test 'parses yaml from first comment' do
        result = Template.parse_metadata(@snippet_text)
        assert_equal 'snippet', result[:kind]
        assert_equal 'snippet', result['kind']
        assert_equal true, result['snippet']
      end

      test 'it ignores other erb tags' do
        assert_nothing_raised do
          assert_equal({}, Template.parse_metadata('<% puts 1 %>'))
        end
      end

      test 'it does not fail on invalid metadata, it just silently ignores them' do
        assert_nothing_raised do
          assert_equal({}, Template.parse_metadata("<%#\n: %>"))
        end
      end
    end

    describe '.import!' do
      test 'by default it does not ignore locking' do
        template = Minitest::Mock.new
        template.expect(:valid?, true)
        template.expect(:save!, true)
        Template.expects(:import_without_save => template)
        Template.import!('test', '')
        template.verify
      end

      test 'locking can be overriden by force option' do
        template = Minitest::Mock.new
        template.expect(:valid?, true)
        template.expect(:ignore_locking, true)
        Template.expects(:import_without_save => template)
        Template.import!('test', '', { :force => true })
        template.verify
      end
    end

    describe "#import_without_save" do
      setup do
        @template.import_without_save(@snippet_text)
      end

      test 'it parses metadata' do
        metadata = @template.instance_variable_get('@importing_metadata')
        metadata_keys = metadata.keys
        assert_includes metadata_keys, 'kind'
        assert_includes metadata_keys, 'name'
        assert_includes metadata_keys, 'model'
        assert_includes metadata_keys, 'snippet'
        assert_not_includes metadata_keys, 'description'
      end

      test 'it sets the snippet flag' do
        assert @template.snippet, 'template was not marked as a snippet'
      end

      test 'snippet flag defaults to false' do
        text = @template.template.sub /snippet: true\n/, ''
        @template = Template.new
        @template.expects :import_locations
        @template.expects :import_organizations
        @template.expects :import_custom_data
        assert_kind_of @template.class, @template.import_without_save(text)
        refute @template.snippet, 'template was not marked as a snippet'
      end

      test 'keeps locked unchanged if lock option was not set' do
        text = @template.template
        @template = Template.new :locked => true
        @template.expects :import_locations
        @template.expects :import_organizations
        @template.expects :import_custom_data
        @template.import_without_save(text)
        assert @template.locked
      end

      test 'keeps locks the template if lock is set to true' do
        text = @template.template
        @template = Template.new
        @template.expects :import_locations
        @template.expects :import_organizations
        @template.expects :import_custom_data
        @template.import_without_save(text, :lock => true)
        assert @template.locked
      end

      test 'unlocks the template if lock is set to false' do
        text = @template.template
        @template = Template.new :locked => true
        @template.expects :import_locations
        @template.expects :import_organizations
        @template.expects :import_custom_data
        @template.import_without_save(text, :lock => false)
        refute @template.locked
      end

      test 'makes the the template default if default option is set to true' do
        text = @template.template
        @template = Template.new
        @template.expects :import_locations
        @template.expects :import_organizations
        @template.expects :import_custom_data
        @template.import_without_save(text, :default => true)
        assert @template.default
      end

      test 'does not save the template' do
        assert @template.new_record?
      end
    end

    describe '#associate_metadata_on_import?' do
      setup do
        @new_template = Template.new
        @existing = FactoryBot.create(:provisioning_template)
      end

      test 'it return true for when associate options is always' do
        assert @new_template.send(:associate_metadata_on_import?, :associate => 'always')
        assert @existing.send(:associate_metadata_on_import?, :associate => 'always')
      end

      test 'it returns true when associate options is new and object is new record' do
        assert @new_template.send(:associate_metadata_on_import?, :associate => 'new')
        refute @existing.send(:associate_metadata_on_import?, :associate => 'new')
      end

      test 'it returns true when associate options is new and object is never or not specified' do
        refute @new_template.send(:associate_metadata_on_import?, :associate => 'never')
        refute @existing.send(:associate_metadata_on_import?, :associate => 'never')
        refute @new_template.send(:associate_metadata_on_import?, {})
        refute @existing.send(:associate_metadata_on_import?, {})
      end
    end

    describe '#import_organizations' do
      setup do
        @template = ProvisioningTemplate.new
        @org1 = FactoryBot.create(:organization)
        @org2 = FactoryBot.create(:organization)
        @org3 = FactoryBot.create(:organization)
      end

      test 'it ignores organizations if none was set in metadata and sets current organization' do
        @template.instance_variable_set '@importing_metadata', {}
        in_taxonomy(@org1) do
          @template.send(:import_organizations, :associate => 'always')
        end
        assert_equal [@org1.id], @template.organization_ids
      end

      test 'it associates organizations with matching prefix' do
        @template.instance_variable_set '@importing_metadata', { 'organizations' => [@org1.name, @org2.name] }
        @template.send(:import_organizations, :associate => 'always')
        assert_includes @template.organization_ids, @org1.id
        assert_includes @template.organization_ids, @org2.id
        refute_includes @template.organization_ids, @org3.id
      end

      test 'unknown organizations are ignored' do
        @template.instance_variable_set '@importing_metadata', { 'organizations' => ['not_available'] }
        assert_nothing_raised { @template.send(:import_oses, :associate => 'always') }
      end

      test 'associated organizations are authorized for current user' do
        @template.instance_variable_set '@importing_metadata', { 'organizations' => [@org1.name, @org2.name, @org3.name] }
        user = FactoryBot.create(:user, :organization_ids => [@org2.id], :location_ids => [taxonomies(:location1).id])
        setup_user 'view', 'organizations', "name = #{@org2}", user
        as_user user do
          @template.send(:import_organizations, :associate => 'always')
        end
        refute_includes @template.organization_ids, @org1.id
        assert_includes @template.organization_ids, @org2.id
        refute_includes @template.organization_ids, @org3.id
      end
    end

    describe '#import_locations' do
      setup do
        @template = ProvisioningTemplate.new
        @loc1 = FactoryBot.create(:location)
        @loc2 = FactoryBot.create(:location)
        @loc3 = FactoryBot.create(:location)
        @loc4 = FactoryBot.create(:location, :ancestry => @loc3.id.to_s)
      end

      test 'it ignores locations if none was set in metadata and sets current location' do
        @template.instance_variable_set '@importing_metadata', {}
        in_taxonomy(@loc1) do
          @template.send(:import_locations, :associate => 'always')
        end
        assert_equal [@loc1.id], @template.location_ids
      end

      test 'it associates locations with matching prefix' do
        @template.instance_variable_set '@importing_metadata', { 'locations' => [@loc1.name, @loc2.name] }
        @template.send(:import_locations, :associate => 'always')
        assert_includes @template.location_ids, @loc1.id
        assert_includes @template.location_ids, @loc2.id
        refute_includes @template.location_ids, @loc3.id
      end

      test 'it properly imports nested locations' do
        @template.instance_variable_set '@importing_metadata', { 'locations' => [@loc4.title] }
        @template.send(:import_locations, :associate => 'always')
        assert_includes @template.location_ids, @loc4.id
      end

      test 'unknown locations are ignored' do
        @template.instance_variable_set '@importing_metadata', { 'locations' => ['not_available'] }
        assert_nothing_raised { @template.send(:import_oses, :associate => 'always') }
      end

      test 'associated locations are authorized for current user' do
        @template.instance_variable_set '@importing_metadata', { 'locations' => [@loc1.name, @loc2.name, @loc3.name] }
        user = FactoryBot.create(:user, :location_ids => [@loc2.id], :organization_ids => [taxonomies(:organization1).id])
        setup_user 'view', 'locations', "name = #{@loc2}", user
        as_user user do
          @template.send(:import_locations, :associate => 'always')
        end
        refute_includes @template.location_ids, @loc1.id
        assert_includes @template.location_ids, @loc2.id
        refute_includes @template.location_ids, @loc3.id
      end
    end

    describe '#import_oses' do
      setup do
        @template = ProvisioningTemplate.new
        @os1 = FactoryBot.create(:operatingsystem, :name => 'my_new_os_1')
        @os2 = FactoryBot.create(:operatingsystem, :name => 'my_new_os_2')
        @os3 = FactoryBot.create(:operatingsystem, :name => 'net_new_os')
      end

      test 'it ignores oses if none was set in metadata' do
        @template.instance_variable_set '@importing_metadata', {}
        assert_nil @template.send(:import_oses, :associate => 'always')
      end

      test 'it associates operating systems with matching prefix' do
        @template.instance_variable_set '@importing_metadata', { 'oses' => ['my_new_os'] }
        @template.send(:import_oses, :associate => 'always')
        assert_includes @template.operatingsystem_ids, @os1.id
        assert_includes @template.operatingsystem_ids, @os2.id
        refute_includes @template.operatingsystem_ids, @os3.id
      end

      test 'unknown oses are ignored' do
        @template.instance_variable_set '@importing_metadata', { 'oses' => ['not_available'] }
        assert_nothing_raised { @template.send(:import_oses, :associate => 'always') }
      end

      test 'associated operating systems are authorized for viewing' do
        @template.instance_variable_set '@importing_metadata', { 'oses' => ['my_new_os'] }
        user = FactoryBot.create(:user, :organization_ids => [taxonomies(:organization1).id], :location_ids => [taxonomies(:location1).id])
        setup_user 'view', 'operatingsystems', "name = #{@os1}", user
        as_user user do
          @template.send(:import_oses, :associate => 'always')
        end
        assert_includes @template.operatingsystem_ids, @os1.id
        refute_includes @template.operatingsystem_ids, @os2.id
      end
    end

    describe '::find_without_name_collision in subclasses' do
      setup do
        @org = FactoryBot.create(:organization, :name => 'TemplateOrg')
        @empty = FactoryBot.create(:organization, :name => 'EmptyOrg')
        @regular_template = FactoryBot.create(:provisioning_template, :name => 'regular template', :organizations => [@org])
        @collision_template = FactoryBot.create(:provisioning_template, :name => 'collision template', :organizations => [@empty])
        @common_template = FactoryBot.create(:provisioning_template, :name => 'common template', :organizations => [@empty, @org])
        @before_org = Organization.current
        Organization.current = @org
      end

      test 'should initialize a new template' do
        template = ProvisioningTemplate.find_without_collision(:name, 'new template')
        assert template.new_record?
        assert template.errors.empty?
      end

      test 'should return existing template in current context' do
        assert_equal @regular_template, ProvisioningTemplate.find_without_collision(:name, 'regular template')
      end

      test 'should return existing template if persent in multiple contexts' do
        assert_equal @common_template, ProvisioningTemplate.find_without_collision(:name, 'common template')
      end

      test 'should return new instance with error when outside of current context' do
        template = ProvisioningTemplate.find_without_collision(:name, 'collision template')
        assert template.new_record?
        refute template.errors.empty?
        assert_equal "cannot be used, please choose another", template.errors.messages[:name].first
      end
    end

    describe 'taxonomies in metadata' do
      test 'should add taxonomies to metadata' do
        org = FactoryBot.create(:organization, :name => 'TemplateOrg')
        loc = FactoryBot.create(:location, :name => 'TemplateLoc')
        provisioning_template = FactoryBot.create(:provisioning_template,
          :name => 'exported_template',
          :organizations => [org],
          :locations => [loc])
        assert_equal org.title, provisioning_template.to_export["organizations"].first
        assert_equal loc.title, provisioning_template.to_export["locations"].first
      end
    end

    describe 'inputs in metadata' do
      let(:exportable_template) do
        FactoryBot.create(:provisioning_template, :with_input)
      end

      let(:erb) do
        exportable_template.to_erb
      end

      it 'exports name' do
        assert_match(/^name: #{exportable_template.name}$/, erb)
      end

      it 'includes template inputs' do
        assert_match(/^template_inputs:$/, erb)
      end

      it 'includes template contents' do
        assert_includes(erb, exportable_template.template)
      end

      it 'is importable' do
        erb
        old_name = exportable_template.name
        exportable_template.update(:name => "#{old_name}_renamed")

        imported = ProvisioningTemplate.import!(old_name, erb)
        assert_equal old_name, imported.name
        assert_equal exportable_template.template_inputs.first.to_export, imported.template_inputs.first.to_export
      end
    end
  end
end
