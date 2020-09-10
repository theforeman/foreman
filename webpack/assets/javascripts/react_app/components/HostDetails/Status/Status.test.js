import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import Status from './';

const fixtures = {
  'should render ok Host Status': {
    status: 'OK',
  },
  'should render error Host Status': {
    status: 'Error',
  },
};

describe('HostDetails - Status', () =>
  testComponentSnapshotsWithFixtures(Status, fixtures));
