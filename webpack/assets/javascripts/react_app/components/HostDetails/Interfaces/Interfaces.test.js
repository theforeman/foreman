import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import IntefacesCard from './';

const fixtures = {
  'should render HostDetails IntefacesCard': {
    interfaces: [
      {
        subnet_id: 1,
        subnet_name: 'subnet name',
        domain_id: 3,
        domain_name: 'tlv.redhat.com',
        managed: true,
        identifier: 'awesome-subnet',
        id: 19,
        name: 'primary name',
        ip: '10.35.2.121',
        ip6: '2620:52:0:2302:5814:9d3:f0c1:a7b6',
        mac: '28:d2:44:69:3a:f2',
        mtu: 1500,
        fqdn: 'fqdn',
        primary: true,
        provision: true,
        type: 'interface',
        virtual: false,
      },
      {
        subnet_id: 1,
        subnet_name: 'another subnet',
        domain_id: 3,
        domain_name: 'tlv.redhat.com',
        managed: true,
        identifier: 'awesome-subnet',
        id: 19,
        name: 'a secondary name',
        ip: '10.35.2.100',
        ip6: '2620:52:0:2302:5814:9d3:f0c1:a84a',
        mac: '28:d2:44:69:3a:f3',
        mtu: 1500,
        fqdn: 'another fqdn',
        primary: false,
        provision: false,
        type: 'interface',
        virtual: true,
      },
    ],
  },
};

describe('HostDetails - Interfaces', () =>
  testComponentSnapshotsWithFixtures(IntefacesCard, fixtures));
