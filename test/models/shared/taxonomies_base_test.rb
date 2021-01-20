module TaxonomiesBaseTest
  extend ActiveSupport::Concern

  included do
    should_not allow_value('').for(:name)
    should_not allow_value('  ').for(:name)
    # Taxonomy 1 is already used by a fixture
    should_not allow_value("#{taxonomy_name} 1").for(:name)
    should_not allow_value(('a' * 256).to_s).for(:name)

    setup do
      User.current = users :admin
    end

    test 'name can be the same if parent is different' do
      assert_difference("#{taxonomy_name.classify}.count", 2) do
        assert taxonomy1 = taxonomy_class.create!(
          :name => "Department A",
          :parent_id => taxonomies(:"#{taxonomy_name}1").id
        )
        assert taxonomy2 = taxonomy_class.create!(
          :name => "Department A",
          :parent_id => taxonomies(:"#{taxonomy_name}2").id
        )
        assert_equal "#{taxonomy1.parent.name}/Department A", taxonomy1.title
        assert_equal "#{taxonomy2.parent.name}/Department A", taxonomy2.title
      end
    end

    test 'it should show the name for to_s' do
      taxonomy = taxonomy_class.new :name => "taxonomy1"
      assert taxonomy.to_s == "taxonomy1"
    end

    test 'taxonomy is valid after fixture mismatches' do
      taxonomy = taxonomies(:"#{taxonomy_name}1")
      Taxonomy.all_import_missing_ids
      assert taxonomy.valid?
    end

    test 'taxonomy is valid if ignore all types' do
      taxonomy = taxonomies(:"#{taxonomy_name}1")
      taxonomy.public_send(:"#{opposite_taxonomy}_ids=",
        [taxonomies(:"#{opposite_taxonomy}1").id])
      taxonomy.ignore_types = ["Domain", "Hostgroup", "User", "Medium", "Subnet",
                               "SmartProxy", "ProvisioningTemplate", "ComputeResource",
                               "Realm"]
      assert taxonomy.valid?
    end

    test 'it should allow assigning invalid opposite_taxonomy' do
      taxonomy = FactoryBot.build(:"#{taxonomy_name}")
      domain = FactoryBot.build(:domain)
      # this makes taxonomy invalid since it has a host in a domain that isn't assigned to it:
      FactoryBot.create(:host, :domain => domain, :"#{taxonomy_name}" => taxonomy)
      refute taxonomy.valid?
      opposite = FactoryBot.build(:"#{opposite_taxonomy}", :"#{taxonomy_name}_ids" => [taxonomy.id])
      assert opposite.valid?
    end

    test 'it should return array of used ids by hosts' do
      taxonomy = taxonomies(:"#{taxonomy_name}1")
      subnet = FactoryBot.build(:subnet_ipv4,
        :"#{opposite_taxonomy}_ids" => [],
        :"#{taxonomy_name.pluralize}" => [taxonomy])
      domain = FactoryBot.build(:domain)
      cr_one = compute_resources(:one)
      cr_one.update(:"#{taxonomy_name.pluralize}" => [taxonomy],
                    :"#{opposite_taxonomy.pluralize}" => [])
      FactoryBot.create(:host,
        :compute_resource => cr_one,
        :domain           => domain,
        :medium           => media(:one),
        :operatingsystem  => operatingsystems(:centos5_3),
        :owner            => users(:scoped),
        :realm            => realms(:myrealm),
        :subnet           => subnet,
        :"#{taxonomy_name}" => taxonomy,
        :"#{opposite_taxonomy}" => nil)
      FactoryBot.create(:os_default_template,
        :provisioning_template  => templates(:mystring2),
        :operatingsystem  => operatingsystems(:centos5_3),
        :template_kind    => TemplateKind.find_by_name('provision'))
      # run used_ids method
      used_ids = taxonomy.used_ids
      # get results from Host object
      hostgroup_ids = Host.where(:"#{taxonomy_name}_id" => taxonomy.id).distinct.pluck(:hostgroup_id).compact
      subnet_ids = Host.where(:"#{taxonomy_name}_id" => taxonomy.id).joins(:primary_interface => :subnet).distinct.pluck(:subnet_id).map(&:to_i).compact
      domain_ids = Host.where(:"#{taxonomy_name}_id" => taxonomy.id).joins(:primary_interface => :domain).distinct.pluck(:domain_id).map(&:to_i).compact
      realm_ids = Host.where(:"#{taxonomy_name}_id" => taxonomy.id).distinct.pluck(:realm_id).compact
      medium_ids = Host.where(:"#{taxonomy_name}_id" => taxonomy.id).distinct.pluck(:medium_id).compact
      compute_resource_ids = Host.where(:"#{taxonomy_name}_id" => taxonomy.id).distinct.pluck(:compute_resource_id).compact
      user_ids = Host.where(:"#{taxonomy_name}_id" => taxonomy.id).where(:owner_type => 'User').distinct.pluck(:owner_id).compact
      smart_proxy_ids = Host.where(:"#{taxonomy_name}_id" => taxonomy.id).map { |host| host.smart_proxies.map(&:id) }.flatten.compact.uniq
      provisioning_template_ids = Host.where("#{taxonomy_name}_id = #{taxonomy.id} and operatingsystem_id > 0").map { |host| host.provisioning_template.try(:id) }.compact.uniq
      # match to above retrieved data
      assert_equal used_ids[:hostgroup_ids], hostgroup_ids
      assert_equal used_ids[:subnet_ids], subnet_ids
      assert_equal used_ids[:domain_ids], domain_ids
      assert_equal used_ids[:realm_ids], realm_ids
      assert_equal used_ids[:medium_ids], medium_ids
      assert_equal used_ids[:compute_resource_ids], compute_resource_ids
      assert_equal used_ids[:user_ids].sort, user_ids.sort
      assert_equal used_ids[:smart_proxy_ids].sort, smart_proxy_ids.sort
      assert_equal used_ids[:provisioning_template_ids], provisioning_template_ids
      # match to raw fixtures data
      assert_equal used_ids[:hostgroup_ids].sort, []
      assert_equal used_ids[:subnet_ids], [subnet.id]
      assert_equal used_ids[:domain_ids], [domain.id]
      assert_equal used_ids[:medium_ids], [media(:one).id]
      assert_equal used_ids[:compute_resource_ids].sort, [compute_resources(:one).id]
      assert_equal used_ids[:user_ids], [users(:scoped).id]
      assert_includes used_ids[:smart_proxy_ids].sort, smart_proxies(:realm).id
      assert_equal used_ids[:provisioning_template_ids].sort, [templates(:mystring2).id]
    end

    test 'it should return selected_ids array of selected values only (when types are not ignored)' do
      taxonomy = taxonomies(:"#{taxonomy_name}1")
      # fixtures for taxable_taxonomies don't work, on has_many :through polymorphic
      # run selected_ids method
      selected_ids = taxonomy.selected_ids
      # get results from taxable_taxonomies
      hostgroup_ids = taxonomy.hostgroup_ids
      subnet_ids = taxonomy.subnet_ids
      domain_ids = taxonomy.domain_ids
      realm_ids = taxonomy.realm_ids
      medium_ids = taxonomy.medium_ids
      user_ids = taxonomy.user_ids
      smart_proxy_ids = taxonomy.smart_proxy_ids
      provisioning_template_ids = taxonomy.provisioning_template_ids
      compute_resource_ids = taxonomy.compute_resource_ids
      # check if they match
      assert_equal selected_ids[:hostgroup_ids].sort, hostgroup_ids.sort
      assert_equal selected_ids[:subnet_ids].sort, subnet_ids.uniq.sort
      assert_equal selected_ids[:domain_ids].sort, domain_ids.sort
      assert_equal selected_ids[:realm_ids].sort, realm_ids.sort
      assert_equal selected_ids[:medium_ids].sort, medium_ids.uniq.sort
      assert_equal selected_ids[:user_ids].sort, user_ids.sort
      assert_equal selected_ids[:smart_proxy_ids].sort, smart_proxy_ids.sort
      assert_equal selected_ids[:provisioning_template_ids].sort, provisioning_template_ids.sort
      assert_equal selected_ids[:compute_resource_ids].sort, compute_resource_ids.sort
      # match to manually generated taxable_taxonomies
      assert_equal selected_ids[:hostgroup_ids], [hostgroups(:common).id]
      assert_equal selected_ids[:subnet_ids].sort, [subnets(:one).id, subnets(:five).id].sort
      assert_equal selected_ids[:domain_ids], [domains(:mydomain).id, domains(:yourdomain).id]
      assert_equal selected_ids[:medium_ids], [media(:one).id]
      assert_equal selected_ids[:user_ids], [users(:one).id, users(:scoped).id]
      assert_equal selected_ids[:smart_proxy_ids].sort, [smart_proxies(:bmc).id, smart_proxies(:puppetmaster).id, smart_proxies(:one).id, smart_proxies(:two).id, smart_proxies(:three).id, smart_proxies(:realm).id].sort
      assert_equal selected_ids[:provisioning_template_ids], [templates(:mystring2).id]
      assert_equal selected_ids[:compute_resource_ids], [compute_resources(:one).id, compute_resources(:mycompute).id]
    end

    test 'it should return selected_ids array of ALL values (when types are ignored)' do
      taxonomy = taxonomies(:"#{taxonomy_name}1")
      # ignore all types
      taxonomy.ignore_types = ["Domain", "Hostgroup", "User", "Medium", "Subnet", "SmartProxy", "ProvisioningTemplate", "ComputeResource", "Realm"]
      # run selected_ids method
      selected_ids = taxonomy.selected_ids
      # should return all when type is ignored
      assert_equal selected_ids[:hostgroup_ids], Hostgroup.pluck(:id)
      assert_equal selected_ids[:subnet_ids], Subnet.pluck(:id)
      assert_equal selected_ids[:domain_ids], Domain.pluck(:id)
      assert_equal selected_ids[:realm_ids], Realm.pluck(:id)
      assert_equal selected_ids[:medium_ids], Medium.pluck(:id)
      assert_equal selected_ids[:user_ids], User.pluck(:id)
      assert_equal selected_ids[:smart_proxy_ids], SmartProxy.pluck(:id)
      assert_equal selected_ids[:provisioning_template_ids], ProvisioningTemplate.pluck(:id)
      assert_equal selected_ids[:compute_resource_ids], ComputeResource.pluck(:id)
    end

    test "it should clone organization with all associations" do
      taxonomy = taxonomies(:"#{taxonomy_name}1")
      taxonomy_dup = taxonomy.dup
      taxonomy_dup.name = "taxonomy_dup_name_#{rand}"
      assert taxonomy_dup.save
      assert_equal taxonomy_dup.hostgroup_ids, taxonomy.hostgroup_ids
      assert_equal taxonomy_dup.subnet_ids, taxonomy.subnet_ids
      assert_equal taxonomy_dup.domain_ids, taxonomy.domain_ids
      assert_equal taxonomy_dup.medium_ids, taxonomy.medium_ids
      assert_equal taxonomy_dup.user_ids, taxonomy.user_ids
      assert_equal taxonomy_dup.smart_proxy_ids.sort, taxonomy.smart_proxy_ids.sort
      assert_equal taxonomy_dup.provisioning_template_ids, taxonomy.provisioning_template_ids
      assert_equal taxonomy_dup.compute_resource_ids, taxonomy.compute_resource_ids
      assert_equal taxonomy_dup.realm_ids, taxonomy.realm_ids
      assert_equal taxonomy_dup.public_send(:"#{opposite_taxonomy}_ids"),
        taxonomy.public_send(:"#{opposite_taxonomy}_ids")
    end

    test "it should have its own class as auditable_type" do
      taxonomy = taxonomies(:"#{taxonomy_name}2")
      assert taxonomy.update!(:name => 'newname')
      assert_equal taxonomy_name.classify, Audit.unscoped.last.auditable_type
    end

    test "non-admin user is added to taxonomy after creating it" do
      user = users(:one)
      setup_user 'create', taxonomy_class.to_s.underscore.pluralize
      as_user(:one) do
        refute user.admin?
        assert taxonomy = taxonomy_class.create(:name => 'new taxonomy')
        assert taxonomy.users.include?(user)
      end
    end

    test ".my_taxonomies returns all taxonomies for admin" do
      as_admin do
        assert_equal taxonomy_class.unscoped.pluck(:id).sort,
          taxonomy_class.public_send(:"my_#{taxonomy_name.pluralize}").pluck(:id).sort
      end
    end

    test ".my_taxonomies optionally accepts user as argument" do
      expected = taxonomy_class.where(
        :id => users(:one).public_send("#{taxonomy_name}_and_child_ids")
      )
      as_admin do
        assert_equal expected.sort,
          taxonomy_class.public_send(:"my_#{taxonomy_name.pluralize}",
            users(:one)).sort
      end
    end

    test ".my_taxonomies returns user's associated taxonomies and children" do
      tax1 = FactoryBot.create(:"#{taxonomy_name}")
      tax2 = FactoryBot.create(:"#{taxonomy_name}", :parent => tax1)
      user = FactoryBot.build(:user, :"#{taxonomy_name.pluralize}" => [tax1])
      as_user(user) do
        assert_equal [tax1.id, tax2.id].sort,
          taxonomy_class.public_send(:"my_#{taxonomy_name.pluralize}").pluck(:id).sort
      end
    end

    # taxonomy_class inheritance tests
    test "inherited taxonomy should have correct path" do
      parent = taxonomies(:"#{taxonomy_name}1")
      taxonomy = taxonomy_class.create!(:name => "rack1", :parent_id => parent.id)
      assert_equal "#{taxonomy_name.humanize} 1/rack1", taxonomy.title
    end

    test "inherited_ids for inherited taxonomy" do
      parent = taxonomies(:"#{taxonomy_name}1")
      taxonomy = taxonomy_class.create :name => "rack1", :parent_id => parent.id
      # check that inherited_ids of taxonomy matches selected_ids of parent
      as_admin do
        assert_equal parent.selected_ids, taxonomy.inherited_ids
      end
    end

    test "selected_or_inherited_ids for inherited taxonomy" do
      parent = taxonomies(:"#{taxonomy_name}1")
      taxonomy = taxonomy_class.create :name => "rack1", :parent_id => parent.id
      # add subnet to taxonomy
      assert TaxableTaxonomy.create(:taxonomy_id => taxonomy.id, :taxable_id => subnets(:two).id, :taxable_type => "Subnet")
      # check that inherited_ids of taxonomy matches selected_ids of parent, except for subnet
      taxonomy.selected_or_inherited_ids.each do |k, v|
        assert_equal v.uniq, parent.selected_ids[k].uniq unless k == 'subnet_ids'
        assert_equal v.uniq, ([subnets(:two).id] + parent.selected_ids[k].uniq) if k == 'subnet_ids'
      end
    end

    test "used_and_selected_or_inherited_ids for inherited taxonomy" do
      parent = taxonomies(:"#{taxonomy_name}1")
      subnet = FactoryBot.create(:subnet_ipv4, :organizations => [taxonomies(:organization1)])
      domain1 = FactoryBot.create(:domain)
      domain2 = FactoryBot.create(:domain)
      parent.update_attribute(:domains, [domain1, domain2])
      parent.update_attribute(:subnets, [subnet])
      # we're no longer using the fixture dhcp/dns/tftp proxy to create the host, so remove them
      parent.update_attribute(:smart_proxies, [smart_proxies(:realm)])

      taxonomy = taxonomy_class.create :name => "rack1", :parent_id => parent.id
      FactoryBot.build(:host,
        :compute_resource => compute_resources(:one),
        :domain           => domain1,
        :"#{taxonomy_name}" => parent,
        :organization     => taxonomies(:organization1),
        :medium           => media(:one),
        :operatingsystem  => operatingsystems(:centos5_3),
        :owner            => users(:scoped),
        :realm            => realms(:myrealm),
        :subnet           => subnet)
      FactoryBot.build(:host,
        :"#{taxonomy_name}" => parent,
        :domain => domain2)
      FactoryBot.build(:os_default_template,
        :provisioning_template => templates(:mystring2),
        :operatingsystem  => operatingsystems(:centos5_3),
        :template_kind    => TemplateKind.find_by_name('provision'))

      # check that inherited_ids of taxonomy matches selected_ids of parent
      taxonomy.inherited_ids.each do |k, v|
        assert_equal v.sort, parent.selected_ids[k].sort
      end
    end

    test "need_to_be_selected_ids for inherited taxonomy" do
      parent = taxonomies(:"#{taxonomy_name}1")
      taxonomy = taxonomy_class.create :name => "rack1", :parent_id => parent.id
      # no hosts were assigned to taxonomy, so no missing ids need to be selected
      taxonomy.need_to_be_selected_ids.each do |k, v|
        assert v.empty?
      end
    end

    test "multiple inheritance" do
      parent1 = taxonomies(:"#{taxonomy_name}1")
      assert_equal [subnets(:one).id, subnets(:five).id].sort, parent1.selected_ids["subnet_ids"].sort

      # inherit from parent 1
      parent2 = taxonomy_class.create :name => "floor1", :parent_id => parent1.id
      assert TaxableTaxonomy.create(:taxonomy_id => parent2.id, :taxable_id => subnets(:two).id, :taxable_type => "Subnet")
      assert_equal [subnets(:one).id, subnets(:five).id, subnets(:two).id].sort, parent2.selected_or_inherited_ids["subnet_ids"].sort

      # inherit from parent 2
      taxonomy = taxonomy_class.create :name => "rack1", :parent_id => parent2.id
      assert TaxableTaxonomy.create(:taxonomy_id => parent2.id, :taxable_id => subnets(:three).id, :taxable_type => "Subnet")
      assert_equal [subnets(:one).id, subnets(:five).id, subnets(:two).id, subnets(:three).id].sort, taxonomy.selected_or_inherited_ids["subnet_ids"].sort
    end

    test "parameter inheritence with no new parameters on child taxonomy" do
      assert_equal [parameters(:"#{taxonomy_name}")], taxonomies(:"#{taxonomy_name}1").public_send("#{taxonomy_name}_parameters")

      # inherit parameter from parent
      taxonomy = taxonomy_class.create :name => "floor1", :parent_id => taxonomies(:"#{taxonomy_name}1").id
      parent_params = taxonomies(:"#{taxonomy_name}1").public_send("#{taxonomy_name}_parameters")
      assert_equal [], taxonomy.public_send("#{taxonomy_name}_parameters")
      assert_equal Hash[tax_param, parent_params.first.value], taxonomy.parameters
    end

    test "parameter inheritence with new parameters on child taxonomy" do
      assert_equal [parameters(:"#{taxonomy_name}")], taxonomies(:"#{taxonomy_name}1").public_send("#{taxonomy_name}_parameters")

      # inherit parameter from parent
      child_taxonomy = taxonomy_class.create :name => "floor1", :parent_id => taxonomies(:"#{taxonomy_name}1").id
      parent_params = taxonomies(:"#{taxonomy_name}1").public_send("#{taxonomy_name}_parameters")
      assert_equal [], child_taxonomy.public_send("#{taxonomy_name}_parameters")

      # new parameter on child taxonomy
      child_taxonomy.public_send("#{taxonomy_name}_parameters").create(:name => "child_param", :value => "123")

      assert_equal Hash[tax_param, parent_params.first.value, 'child_param', '123'],
        child_taxonomy.parameters
    end

    test "parent_params returns only ancestors parameters" do
      assert_equal [parameters(:"#{taxonomy_name}")], taxonomies(:"#{taxonomy_name}1").public_send("#{taxonomy_name}_parameters")

      # inherit parameter from parent
      child_taxonomy = taxonomy_class.create :name => "floor1", :parent_id => taxonomies(:"#{taxonomy_name}1").id
      parent_params = taxonomies(:"#{taxonomy_name}1").public_send("#{taxonomy_name}_parameters")
      assert_equal [], child_taxonomy.public_send("#{taxonomy_name}_parameters")

      # new parameter on child taxonomy
      child_taxonomy.public_send("#{taxonomy_name}_parameters").create(:name => "child_param", :value => "123")

      assert_equal({ tax_param => parent_params.first.value }, child_taxonomy.parent_params)
    end

    test "#params_objects should return taxonomy parameters" do
      taxonomy = taxonomy_class.create :name => "floor1"
      param = "#{taxonomy_name}Parameter".classify.constantize.
        create(:name => 'name', :value => 'valueable')
      taxonomy.public_send("#{taxonomy_name}_parameters=", [param])
      assert(taxonomy.params_objects.include?(param))
    end

    test "#params_objects should return ancestors parameters" do
      taxonomy = taxonomy_class.create :name => "floor1", :parent_id => taxonomies(:"#{taxonomy_name}1").id
      assert_equal [], taxonomy.public_send("#{taxonomy_name}_parameters")
      assert_equal [taxonomies(:"#{taxonomy_name}1").public_send("#{taxonomy_name}_parameters")], taxonomy.params_objects
    end

    test "cannot delete taxonomy that is a parent for nested taxonomy" do
      parent1 = taxonomies(:"#{taxonomy_name}2")
      taxonomy_class.create :name => "floor1", :parent_id => parent1.id
      assert_raise Ancestry::AncestryException do
        parent1.destroy
      end
    end

    test "taxonomy name can be up to 255 characters" do
      parent = FactoryBot.create(:"#{taxonomy_name}")
      min_lookupvalue_length = "#{taxonomy_name}=".length + parent.title.length + 1
      taxonomy = taxonomy_class.new :parent => parent, :name => 'a' * (255 - min_lookupvalue_length)
      assert_valid taxonomy
    end

    test 'ignores the taxable_type if current taxonomy ignores it' do
      taxonomy = taxonomies(:"#{taxonomy_name}1")
      assert_empty taxonomy.ignore_types
      taxonomy.ignore_types << 'Domain'
      in_taxonomy(taxonomy) do
        assert taxonomy_class.ignore?('Domain')
      end
    end

    test "'no current Taxonomy' is understood as 'any taxonomy'" do
      taxonomy = taxonomies(:"#{taxonomy_name}1")
      assert_empty taxonomy.ignore_types
      taxonomy.ignore_types << 'Domain'
      User.current.public_send("#{taxonomy_name.pluralize}=", [taxonomy])
      refute taxonomy_class.current
      assert taxonomy_class.ignore?('Domain')
    end

    def taxonomy_name
      self.class.name.sub('Test', '').downcase
    end

    def taxonomy_class
      taxonomy_name.classify.constantize
    end

    def opposite_taxonomy
      return 'organization' if taxonomy_name == 'location'
      'location'
    end

    def tax_param
      return 'loc_param' if taxonomy_name == 'location'
      'org_param'
    end
  end

  # Redefine these so the can be used on shoulda-matchers tests
  module ClassMethods
    def taxonomy_name
      name.sub('Test', '')
    end

    def taxonomy_class
      taxonomy_name.constantize
    end
  end
end
