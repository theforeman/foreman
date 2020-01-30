import { testSelectorsSnapshotWithFixtures } from '@theforeman/test';

import {
  selectSettingsPage,
  selectSettings,
  selectHasError,
  selectIsLoading,
  selectHasData,
  selectErrorMsg,
  selectGroupedSettings,
  selectSettingGroup,
} from '../SettingsPageSelectors';

import { settings } from './SettingsPage.fixtures';

const stateFactory = (state = {}) => ({
  settingsPage: {
    pageContent: {
      isLoading: false,
      hasError: false,
      hasData: true,
      message: {},
      results: [],
      ...state,
    },
  },
});

const fixtures = {
  'should return settings page state': () => selectSettingsPage(stateFactory()),
  'should return settings': () =>
    selectSettings(stateFactory({ results: settings })),
  'should return page error': () => selectHasError(stateFactory()),
  'should return page loading state': () => selectIsLoading(stateFactory()),
  'should return page has data': () => selectHasData(stateFactory()),
  'should select page error msg': () =>
    selectErrorMsg(stateFactory({ errorMsg: { type: 500, text: 'Error' } })),
  'should select grouped settings': () =>
    selectGroupedSettings(stateFactory({ results: settings })),
  'should select settings group': () =>
    selectSettingGroup(stateFactory({ results: settings }))('Setting::General'),
};

describe('SettingsPageSelectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
