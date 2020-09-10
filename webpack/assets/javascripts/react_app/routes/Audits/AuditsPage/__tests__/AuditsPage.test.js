import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import AuditsPage from '../AuditsPage';
import { auditsPageProps } from '../AuditsPage.fixtures';

const auditsPageFixtures = {
  'render audits page': auditsPageProps,
  'render loading audits page': {
    ...auditsPageProps,
    hasError: false,
    hasData: true,
    audits: [],
  },
  'render audits page w/empty audits': {
    ...auditsPageProps,
    hasError: true,
    message: 'no audits',
  },
  'render audits page w/error': {
    ...auditsPageProps,
    hasError: true,
    message: 'some-error',
  },
};

describe('AuditsPage', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(AuditsPage, auditsPageFixtures));
});
