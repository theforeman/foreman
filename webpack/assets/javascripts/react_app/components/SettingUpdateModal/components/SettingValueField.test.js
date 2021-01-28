import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import SettingValueField from './SettingValueField';

import {
  arraySetting,
  withArraySelection,
  withHashSelection,
  boolSetting,
  stringSetting,
  rootPass,
} from '../../SettingRecords/__tests__/SettingRecords.fixtures';

const baseFixtures = {
  form: {},
  field: {},
};

const fixtures = {
  'should render for string setting': {
    setting: stringSetting,
    ...baseFixtures,
  },
  'should render for array setting': {
    setting: arraySetting,
    ...baseFixtures,
  },
  'should render for bool setting': {
    setting: boolSetting,
    ...baseFixtures,
  },
  'should render for setting with hash selection': {
    setting: withHashSelection,
    ...baseFixtures,
  },
  'should render for setting with array selection': {
    setting: withArraySelection,
    ...baseFixtures,
  },
  'should render for encrypted setting': {
    setting: rootPass,
    ...baseFixtures,
  },
};

describe('SettingValueField', () =>
  testComponentSnapshotsWithFixtures(SettingValueField, fixtures));
