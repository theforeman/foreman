import { testComponentSnapshotsWithFixtures } from 'foremanReact/common/testHelpers';

import {
  rootPass,
  stringSetting,
  withoutFullName,
} from '../../../SettingRecords/__tests__/SettingRecords.fixtures';

import SettingValue from '../SettingValue';

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
  testComponentSnapshotsWithFixtures(SettingValue, fixtures));
