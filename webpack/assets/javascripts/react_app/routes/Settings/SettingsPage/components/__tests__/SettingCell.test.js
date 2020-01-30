import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import SettingCell from '../SettingCell';

const fixtures = {
  'should render readonly setting': {
    setting: {
      name: 'readonly_setting',
      readonly: true,
      configFile: 'settings.yaml',
    },
  },
  'should render editable setting': {
    setting: {
      name: 'editable_setting',
      fullName: 'Editable setting',
      onEditClick: () => {},
    },
  },
};

describe('SettingCell', () =>
  testComponentSnapshotsWithFixtures(SettingCell, fixtures));
