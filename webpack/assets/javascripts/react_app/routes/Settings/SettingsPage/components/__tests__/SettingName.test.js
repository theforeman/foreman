import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import SettingName from '../SettingName';

const fixtures = {
  'should render': {
    setting: { fullName: 'Test setting' },
  },
};

describe('SettingName', () =>
  testComponentSnapshotsWithFixtures(SettingName, fixtures));
