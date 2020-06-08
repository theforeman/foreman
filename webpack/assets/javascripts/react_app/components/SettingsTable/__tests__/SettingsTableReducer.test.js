import { testReducerSnapshotWithFixtures } from '@theforeman/test';

import { default as reducer, initialState } from '../SettingsTableReducer';

import { SET_UPDATE_SETTING } from '../SettingsTableConstants';

const fixtures = {
  'should set setting to update': {
    state: initialState,
    action: {
      type: SET_UPDATE_SETTING,
      payload: {
        setting: {
          id: 5,
          category: 'Setting::Email',
          name: 'email_reply_address',
        },
      },
    },
  },
};

describe('SettingsTableReducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
