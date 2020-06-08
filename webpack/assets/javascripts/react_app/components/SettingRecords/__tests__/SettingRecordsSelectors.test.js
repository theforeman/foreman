import { testSelectorsSnapshotWithFixtures } from '@theforeman/test';

import {
  selectSettings,
  selectSettingsByCategory,
  selectSettingById,
} from '../SettingRecordsSelectors';

import { groupedSettings } from './SettingRecords.fixtures';

const state = {
  settingRecords: {
    settings: groupedSettings,
  },
};

const fixtures = {
  'should select setting records': () => selectSettings(state),
  'should select settings by category': () =>
    selectSettingsByCategory(state, 'Setting::General'),
  'should select setting by id': () =>
    selectSettingById(state, 36, 'Setting::Email'),
};

describe('SettingRecordsSelectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
