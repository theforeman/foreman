import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import SettingsPage from '../SettingsPage';

const fixtures = {
  'should render': {
    pageParams: { search: '' },
    isLoading: true,
    hasData: false,
    fetchAndPush: () => {},
    hasError: false,
    errorMsg: {},
    groupedSettings: {},
  },
};

describe('SettingsPage', () =>
  testComponentSnapshotsWithFixtures(SettingsPage, fixtures));
