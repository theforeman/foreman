import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import ParametersCard from './';

const fixtures = {
  'should render HostDetails ParametersCard': {
    paramters: [
      {
        id: 1,
        name: 'global',
        parameter_type: 'string',
        value: 'true',
      },
      {
        id: 2,
        name: 'local',
        parameter_type: 'string',
        value: '--- false\r\n...\r\n',
      },
    ],
  },
};

describe('HostDetails - ParametersCard', () =>
  testComponentSnapshotsWithFixtures(ParametersCard, fixtures));
