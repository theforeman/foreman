import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import Layout from '../Layout';
import { layoutMock } from '../Layout.fixtures';

const fixtures = {
  'renders layout': layoutMock,
};

describe('Layout', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(Layout, fixtures));
});
