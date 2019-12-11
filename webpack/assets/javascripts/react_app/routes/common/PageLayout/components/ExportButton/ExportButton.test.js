import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import ExportButton from './ExportButton';

const fixtures = {
  'render without props': {},
  'render with props': { url: 'url', title: 'title info', text: 'info' },
};

describe('ExportButton', () =>
  testComponentSnapshotsWithFixtures(ExportButton, fixtures));
