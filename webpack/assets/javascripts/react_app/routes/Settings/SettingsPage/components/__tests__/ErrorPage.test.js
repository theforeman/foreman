import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import ErrorPage from '../ErrorPage';

const fixtures = {
  'should render': {
    errorMsg: {
      type: '500',
      text: 'Unknown error',
    },
  },
};

describe('ErrorPage', () =>
  testComponentSnapshotsWithFixtures(ErrorPage, fixtures));
