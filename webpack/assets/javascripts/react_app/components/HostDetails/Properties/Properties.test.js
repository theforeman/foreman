import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import PropertiesCard from './';

const fixtures = {
  'should render UserProfile': {
    hostData: {
      operatingsystem_name: 'windows 3.11',
      domain_name: 'altavista',
      architecture_name: 'x16',
      ip: '0.0.0.1',
      ip6: '',
      mac: '00:0a:95:9d:68:16',
      location_name: 'Beverly Hills',
      organization_name: '90210',
    },
  },
};

describe('HostDetails - Interfaces', () =>
  testComponentSnapshotsWithFixtures(PropertiesCard, fixtures));
