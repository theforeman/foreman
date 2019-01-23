import { testActionSnapshotWithFixtures } from 'react-redux-test-utils';

import API from '../../../API';

import { loadSetting } from '../SettingsActions';

jest.mock('../../../API');

const successResponse = {
  data: 'some-data',
};

const doLoadSettings = (settingName, serverMock) => {
  API.get.mockImplementation(serverMock);

  return loadSetting(settingName);
};

const fixtures = {
  'should load settings and success': () =>
    doLoadSettings('some-name', async () => successResponse),

  'should load settings and fail': () =>
    doLoadSettings('some-name', async () => {
      throw new Error('some-error');
    }),
};

describe('Settings actions', () => testActionSnapshotWithFixtures(fixtures));
