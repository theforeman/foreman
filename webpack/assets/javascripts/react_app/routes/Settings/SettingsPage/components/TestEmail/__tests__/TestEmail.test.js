import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import TestEmail from '../TestEmail';

const testEmail = () => {};

const fixtures = {
  'should render': {
    loading: false,
    testEmail,
  },
  'should render when loading': {
    loading: true,
    testEmail,
  },
};

describe('TestEmail', () =>
  testComponentSnapshotsWithFixtures(TestEmail, fixtures));
