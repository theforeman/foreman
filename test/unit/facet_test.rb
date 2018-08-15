require 'test_helper'

class TestFacet < HostFacets::Base
end

module TestModule
  class ModuleTestFacet < HostFacets::Base
  end
end

class FacetTest < ActiveSupport::TestCase
  setup do
    @config = {}
    Facets.stubs(:configuration).returns(@config)
  end

  teardown do
    Host::Managed.cloned_parameters[:include].delete(:test_model)
    Host::Managed.cloned_parameters[:include].delete(:test_facet)
    Host::Managed.cloned_parameters[:include].delete(:namespaced_facet)
  end

  context 'namespaced facets' do
    setup do
      Facets.register TestModule::ModuleTestFacet, :namespaced_facet

      @host = Host::Managed.new
      @facet = @host.build_namespaced_facet
    end

    test 'can create a namespaced facet' do
      assert_equal @facet, @host.facets.first
    end

    test 'returns facets attributes' do
      attributes = @host.attributes

      assert_not_nil attributes["namespaced_facet_attributes"]
    end
  end

  context 'managed host behavior' do
    setup do
      Facets.register TestFacet

      @host = Host::Managed.new
      @facet = @host.build_test_facet
    end

    test 'registered facets are subscribed properly' do
      assert_equal @facet, @host.facets.first
    end

    test 'facets are cloned to the new host' do
      facet_clone = @facet.dup
      @facet.stubs(:dup).returns(facet_clone)

      cloned_host = @host.clone

      assert_equal facet_clone, cloned_host.test_facet
      assert_equal facet_clone, cloned_host.facets.first
    end

    test 'facets are included in attributes' do
      attributes = @host.attributes

      assert_not_nil attributes["test_facet_attributes"]
    end

    test 'apply_inherited_attributes is augmented by facets' do
      attributes = { 'hostgroup_id' => 1 }
      @host.hostgroup = Hostgroup.new(:id => 1)

      TestFacet.expects(:inherited_attributes).returns({ :test_attribute => :test_value })
      actual_attributes = @host.apply_inherited_attributes(attributes)

      assert_equal :test_value, actual_attributes['test_facet_attributes'][:test_attribute]
    end

    test 'apply_inherited_attributes works facet defaults' do
      attributes = { 'hostgroup_id' => 1 }
      @host.hostgroup = Hostgroup.new(:id => 1)

      @host.apply_inherited_attributes(attributes)
    end

    test 'facet attributes are passed to Facet.inherited_attributes' do
      attributes = {  'hostgroup_id' => 1, 'test_facet_attributes' => { :test_attribute => :test_value }}
      @host.hostgroup = Hostgroup.new

      TestFacet.expects(:inherited_attributes).with do |hostgroup, facet_attributes|
        facet_attributes[:test_attribute] == :test_value
      end

      @host.apply_inherited_attributes(attributes)
    end

    test 'facts are parsed by facets too' do
      TestFacet.expects(:populate_fields_from_facts)
      @host.stubs(:save)
      facts_json = read_json_fixture('facts/brslc022.facts.json')

      @host.parse_facts(facts_json['facts'], nil, nil)
    end
  end

  context "managed host facet behavior" do
    setup do
      TestFacet.class_eval do
        def my_attribute
        end

        def my_attribute=(val)
        end
      end

      Facets.register TestFacet
    end

    test 'facets are updated without specifying id explicitly' do
      saved_host = FactoryBot.build(:host)
      saved_host.build_test_facet
      saved_host.save!
      saved_host.attributes = {'test_facet_attributes' => { 'my_attribute' => 'my_value'}}
      assert_not_nil saved_host.test_facet.id
    end

    test 'facets do not get created for nil attributes and viceversa' do
      saved_host = FactoryBot.build(:host)

      saved_host.update({'test_facet_attributes' => { 'my_attribute' => nil}})
      assert_nil saved_host.test_facet

      saved_host.update({'test_facet_attributes' => { 'my_attribute' => "val"}})
      assert_not_nil saved_host.test_facet
    end

    test 'facet is not removed when associated host is deleted' do
      as_admin do
        saved_host = FactoryBot.create(:host)
        facet = saved_host.build_test_facet
        saved_host.save!
        assert facet.id
        saved_host.destroy!
        assert TestFacet.find_by(id: facet.id)
      end
    end
  end

  context 'managed host facet dependent destroy behavior' do
    setup do
      Facets.register TestFacet do
        set_dependent_action :destroy
      end
    end

    test 'facet is removed when associated host is deleted' do
      as_admin do
        saved_host = FactoryBot.create(:host)
        facet = saved_host.build_test_facet
        saved_host.save!
        assert facet.id
        saved_host.destroy!
        refute TestFacet.find_by(id: facet.id)
      end
    end
  end

  context 'inside db:migrate task' do
    setup do
      Foreman.stubs(:in_setup_db_rake?).returns(true)
    end

    test 'facet can be registered more than once' do
      # register facet twice
      Facets.register TestFacet
      Facets.register TestFacet

      @host = Host::Managed.new

      @host.test_facet
    end
  end
end
