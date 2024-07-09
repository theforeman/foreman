import { testComponentSnapshotsWithFixtures } from 'foremanReact/common/testHelpers';

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
