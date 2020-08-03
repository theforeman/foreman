import { testSelectorsSnapshotWithFixtures } from '@theforeman/test';

import {
  selectSettings,
  selectSettingsByCategory,
  selectSettingById,
  selectSettingEditing,
} from '../SettingRecordsSelectors';

import { groupedSettings } from './SettingRecords.fixtures';

const state = {
  settingRecords: {
    settings: groupedSettings,
    editing: {
      id: 42,
      category: 'Setting::Foo',
      name: 'edit_me',
    },
  },
};

const fixtures = {
  'should select setting records': () => selectSettings(state),
  'should select settings by category': () =>
    selectSettingsByCategory('Setting::General')(state),
  'should select setting by id': () =>
    selectSettingById(36, 'Setting::Email')(state),
  'should select setting to edit': () => selectSettingEditing(state),
};

describe('SettingRecordsSelectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
