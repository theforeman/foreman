import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import ExportButton from './ExportButton';

const fixtures = {
  'render with minimal props': { url: 'url' },
};

describe('ExportButton', () =>
  testComponentSnapshotsWithFixtures(ExportButton, fixtures));
