require 'test_helper'

module Mutations
  module Hosts
    class CreateMutationTest < GraphQLQueryTestCase
      let(:tax_location) { as_admin { FactoryBot.create(:location) } }
      let(:location_id) { Foreman::GlobalId.for(tax_location) }
      let(:organization) { as_admin { FactoryBot.create(:organization) } }
      let(:organization_id) { Foreman::GlobalId.for(organization) }
      let(:architecture) { as_admin { FactoryBot.create(:architecture) } }
      let(:architecture_id) { Foreman::GlobalId.for(architecture) }
      let(:subnet) { as_admin { FactoryBot.create(:subnet_ipv4, network: '192.0.2.0', locations: [tax_location], organizations: [organization]) } }
      let(:subnet_id) { Foreman::GlobalId.for(subnet) }
      let(:medium) { as_admin { FactoryBot.create(:medium, locations: [tax_location], organizations: [organization]) } }
      let(:medium_id) { Foreman::GlobalId.for(medium) }
      let(:ptable) { as_admin { FactoryBot.create(:ptable, locations: [tax_location], organizations: [organization]) } }
      let(:ptable_id) { Foreman::GlobalId.for(ptable) }
      let(:operatingsystem) { as_admin { FactoryBot.create(:operatingsystem, media: [medium], ptables: [ptable], architectures: [architecture]) } }
      let(:operatingsystem_id) { Foreman::GlobalId.for(operatingsystem) }
      let(:compute_resource) { as_admin { FactoryBot.create(:compute_resource, :vmware, locations: [tax_location], organizations: [organization]) } }
      let(:compute_resource_id) { Foreman::GlobalId.encode('ComputeResource', compute_resource.id) }
      let(:compute_profile) { as_admin { FactoryBot.create(:compute_profile, :with_compute_attribute, compute_resource: compute_resource) } }
      let(:compute_profile_id) { Foreman::GlobalId.for(compute_profile) }
      let(:domain) { as_admin { FactoryBot.create(:domain, subnets: [subnet], locations: [tax_location], organizations: [organization]) } }
      let(:domain_id) { Foreman::GlobalId.for(domain) }
      let(:owner) { as_admin { FactoryBot.create(:user, locations: [tax_location], organizations: [organization]) } }
      let(:owner_id) { Foreman::GlobalId.for(owner) }
      let(:mac) { '00:11:22:33:44:55' }
      let(:ip) { '192.0.2.1' }
      let(:root_pass) { 'graphql-is-great' }
      let(:hostname) { 'my-graphql-host' }

      let(:base_variables) do
        {
          name: hostname,
          ip: ip,
          locationId: location_id,
          organizationId: organization_id,
          architectureId: architecture_id,
          subnetId: subnet_id,
          operatingsystemId: operatingsystem_id,
          ptableId: ptable_id,
          mediumId: medium_id,
          domainId: domain_id,
          ownerId: owner_id,
          rootPass: root_pass,
          build: true,
        }
      end
      let(:variables) do
        base_variables.merge(
          mac: mac
        )
      end
      let(:query) do
        <<-GRAPHQL
          mutation createHostMutation(
              $architectureId: ID!,
              $build: Boolean,
              $computeAttributes: RawJson,
              $computeProfileId: ID,
              $computeResourceId: ID,
              $domainId: ID,
              $interfacesAttributes: [InterfaceAttributesInput!]
              $ip: String,
              $locationId: ID!,
              $mac: String,
              $mediumId: ID!,
              $name: String!,
              $operatingsystemId: ID!,
              $organizationId: ID!,
              $ownerId: ID,
              $ptableId: ID!,
              $rootPass: String,
              $subnetId: ID
            ) {
            createHost(input: {
              architectureId: $architectureId,
              build: $build,
              computeAttributes: $computeAttributes,
              computeProfileId: $computeProfileId,
              computeResourceId: $computeResourceId,
              domainId: $domainId,
              interfacesAttributes: $interfacesAttributes
              ip: $ip,
              locationId: $locationId,
              mac: $mac,
              mediumId: $mediumId,
              name: $name,
              operatingsystemId: $operatingsystemId,
              organizationId: $organizationId,
              ownerId: $ownerId,
              ptableId: $ptableId,
              rootPass: $rootPass,
              subnetId: $subnetId,
            }) {
              host {
                id,
                name,
                ip,
                mac,
                build,
                managed,
                location {
                  id
                },
                organization {
                  id
                }
                subnet {
                  id
                }
                operatingsystem {
                  id
                }
                domain {
                  id
                }
                medium {
                  id
                }
                ptable {
                  id
                }
                owner {
                  ... on User {
                    id
                  }
                  ... on Usergroup {
                    id
                  }
                }
              },
              errors {
                path
                message
              }
            }
          }
        GRAPHQL
      end

      setup :disable_orchestration

      context 'with admin permissions' do
        let(:context_user) { FactoryBot.create(:user, :admin, locations: [tax_location], organizations: [organization]) }
        let(:data) { result['data']['createHost']['host'] }

        context 'with bare metal parameters' do
          it 'creates a bare metal host' do
            assert_difference(-> { Host.count }, +1) do
              assert_empty result['errors']
              assert_empty result['data']['createHost']['errors']
              assert_not_nil data

              assert_equal "#{hostname}.#{domain.name}", data['name']
              assert_equal ip, data['ip']
              assert_equal mac, data['mac']
              assert_equal true, data['build']
              assert_equal true, data['managed']
              assert_equal location_id, data['location']['id']
              assert_equal organization_id, data['organization']['id']
              assert_equal operatingsystem_id, data['operatingsystem']['id']
              assert_equal subnet_id, data['subnet']['id']
              assert_equal domain_id, data['domain']['id']
              assert_equal medium_id, data['medium']['id']
              assert_equal ptable_id, data['ptable']['id']
              assert_equal owner_id, data['owner']['id']
            end
            assert_equal context_user.id, Audit.last.user_id
          end

          context 'with compute resource parameters' do
            setup { Fog.mock! }
            teardown { Fog.unmock! }

            let(:variables) do
              base_variables.merge(
                computeResourceId: compute_resource_id,
                computeAttributes: {
                  cpus: 4,
                  memory: 1024,
                  volumes_attributes: [
                    {
                      size_gb: 50,
                      storage_pod: 'DC1-Storage-01',
                    },
                  ],
                },
                interfacesAttributes: [
                  {
                    computeAttributes: {
                      type: 'VirtualVmxnet3',
                      network: 'dvportgroup-1288722',
                    },
                  },
                ]
              )
            end

            it 'creates a host on a compute resource' do
              assert_difference(-> { Host.count }, +1) do
                assert_empty result['errors']
                assert_empty result['data']['createHost']['errors']
                assert_not_nil data
              end
            end
          end

          context 'with compute profile parameters' do
            setup { Fog.mock! }
            teardown { Fog.unmock! }

            let(:variables) do
              base_variables.merge(
                computeProfileId: compute_profile_id,
                computeResourceId: compute_resource_id
              )
            end

            it 'creates a host with a compute profile' do
              Foreman::Model::Vmware.any_instance.expects(:parse_args).with(compute_profile.compute_attributes.first.vm_attrs).returns({})
              assert_difference(-> { Host.count }, +1) do
                assert_empty result['errors']
                assert_empty result['data']['createHost']['errors']
                assert_not_nil data
              end
            end
          end

          context 'with bare metal bond parameters' do
            let(:variables) do
              base_variables.merge(
                interfacesAttributes: [
                  {
                    type: 'bond',
                    attachedTo: ['eth0', 'eth1'],
                    identifier: 'bond0',
                    primary: true,
                    provision: true,
                    managed: true,
                  },
                  {
                    type: 'interface',
                    identifier: 'eth0',
                    mac: '00:11:22:33:44:11',
                    primary: false,
                    provision: false,
                    managed: true,
                  },
                  {
                    type: 'interface',
                    identifier: 'eth1',
                    mac: '00:11:22:33:44:22',
                    primary: false,
                    provision: false,
                    managed: true,
                  },
                ]
              )
            end

            it 'creates a host with a bonded interface' do
              assert_difference(-> { Host.count }, +1) do
                assert_empty result['errors']
                assert_empty result['data']['createHost']['errors']
                assert_not_nil data
              end

              host = Host.find_by(name: "#{hostname}.#{domain.name}")
              assert_not_nil host

              assert_equal 3, host.interfaces.count
              assert_equal 'Nic::Bond', host.primary_interface.type
              assert_equal subnet, host.primary_interface.subnet
              assert_equal domain, host.primary_interface.domain
              assert_equal 'Nic::Managed', host.interfaces.detect { |nic| nic.identifier == 'eth0' }.type
              assert_equal 'Nic::Managed', host.interfaces.detect { |nic| nic.identifier == 'eth1' }.type
            end
          end
        end
      end

      context 'with create permission' do
        let(:context_user) do
          setup_user('create', 'hosts') do |user|
            user.roles << Role.find_by(name: 'Viewer')
          end
        end
        let(:data) { result['data']['createHost']['host'] }

        before do
          Location.current = tax_location
          Organization.current = organization
        end

        it 'creates a bare metal host' do
          assert_difference(-> { Host.count }, +1) do
            assert_empty result['errors']
            assert_empty result['data']['createHost']['errors']
            assert_not_nil data

            assert_equal "#{hostname}.#{domain.name}", data['name']
            assert_equal ip, data['ip']
            assert_equal mac, data['mac']
            assert_equal true, data['build']
            assert_equal true, data['managed']
            assert_equal location_id, data['location']['id']
            assert_equal organization_id, data['organization']['id']
            assert_equal operatingsystem_id, data['operatingsystem']['id']
            assert_equal subnet_id, data['subnet']['id']
            assert_equal domain_id, data['domain']['id']
            assert_equal medium_id, data['medium']['id']
            assert_equal ptable_id, data['ptable']['id']
            assert_equal owner_id, data['owner']['id']
          end
          assert_equal context_user.id, Audit.last.user_id
        end
      end

      context 'with view only permissions' do
        let(:context_user) do
          setup_user('show', 'hosts') do |user|
            user.roles << Role.find_by(name: 'Viewer')
          end
        end

        before do
          Location.current = tax_location
          Organization.current = organization
        end

        test 'cannot create a host' do
          expected_error = 'Unauthorized. You do not have the required permission create_hosts.'

          assert_difference(-> { Host.count }, 0) do
            assert_not_empty result['errors']
            assert_includes result['errors'].map { |e| e['message'] }, expected_error
          end
        end
      end
    end
  end
end
