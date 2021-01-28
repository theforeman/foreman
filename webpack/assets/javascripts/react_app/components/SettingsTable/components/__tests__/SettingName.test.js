import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import {
  rootPass,
  withoutFullName,
} from '../../../SettingRecords/__tests__/SettingRecords.fixtures';

import SettingName from '../SettingName';

const fixtures = {
  'render with fullName': {
    setting: rootPass,
  },
  'render without fullName': {
    setting: withoutFullName,
  },
};

describe('SettingName', () =>
  testComponentSnapshotsWithFixtures(SettingName, fixtures));
