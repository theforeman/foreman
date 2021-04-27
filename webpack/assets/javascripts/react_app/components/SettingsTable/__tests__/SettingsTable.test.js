import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import { groupedSettings } from '../../SettingRecords/__tests__/SettingRecords.fixtures';

import SettingsTable from '../SettingsTable';

const fixtures = {
  'should render': {
    settings: groupedSettings['General'],
    onEditClick: () => {},
  },
};

describe('SettingsTable', () =>
  testComponentSnapshotsWithFixtures(SettingsTable, fixtures));
