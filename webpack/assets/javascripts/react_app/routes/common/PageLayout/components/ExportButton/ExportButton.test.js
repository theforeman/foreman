import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import ExportButton from './ExportButton';

const fixtures = {
  'render without props': {},
  'render with props': { url: 'url', title: 'title info', text: 'info' },
};

describe('ExportButton', () =>
  testComponentSnapshotsWithFixtures(ExportButton, fixtures));
