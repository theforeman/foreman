import { testSelectorsSnapshotWithFixtures } from '@theforeman/test';

import { selectSettingToEdit } from '../SettingsTableSelectors';

const state = {
  settingsTable: {
    toEdit: {
      id: 42,
      category: 'Setting::Foo',
      name: 'edit_me',
    },
  },
};

const fixtures = {
  'should select setting to edit': () => selectSettingToEdit(state),
};

describe('SettingsTableSelectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
