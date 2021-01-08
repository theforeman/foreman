import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import {
  rootPass,
  stringSetting,
  withoutFullName,
} from '../../../SettingRecords/__tests__/SettingRecords.fixtures';

import SettingCell from '../SettingCell';

const fixtures = {
  'render ordinary': {
    setting: stringSetting,
  },
  'render encrypted with fullName': {
    setting: rootPass,
  },
  'render without fullName': {
    setting: withoutFullName,
  },
};

describe('SettingCell', () =>
  testComponentSnapshotsWithFixtures(SettingCell, fixtures));
