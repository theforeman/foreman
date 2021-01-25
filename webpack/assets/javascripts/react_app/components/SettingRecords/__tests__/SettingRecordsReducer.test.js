import { testReducerSnapshotWithFixtures } from '@theforeman/test';

import { default as reducer, initialState } from '../SettingRecordsReducer';

import { groupedSettings } from './SettingRecords.fixtures';

import {
  LOAD_SETTING_RECORDS,
  SETTINGS_FORM_SUBMITTED_SUCCESS,
  SET_EDITING_SETTING,
} from '../SettingRecordsConstants';

const fixtures = {
  'should return initial state': {},
  'should load settings': {
    state: initialState,
    action: {
      type: LOAD_SETTING_RECORDS,
      payload: groupedSettings,
    },
  },
  'should update a setting': {
    state: initialState.set('settings', groupedSettings),
    action: {
      type: SETTINGS_FORM_SUBMITTED_SUCCESS,
      response: {
        id: 'http_proxy_except_list',
        value: 'http://proxy.com',
        category: 'Setting::General',
      },
    },
  },
  'should set setting to update': {
    state: initialState,
    action: {
      type: SET_EDITING_SETTING,
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

describe('SettingRecordsReducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
