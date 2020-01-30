import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import SettingsPageContent from '../SettingsPageContent';
import { groupSettings } from '../../SettingsPageHelpers';

import { settings } from '../../__tests__/SettingsPage.fixtures';

const fixtures = {
  'should render when loading': {
    isLoading: true,
    hasData: false,
  },
  'should render on error': {
    isLoading: false,
    hasData: false,
    hasError: true,
    errorMsg: {
      type: '500',
      text: 'Unknown error',
    },
  },
  'should render on data': {
    isLoading: false,
    hasData: true,
    hasError: false,
    groupedSettings: groupSettings(settings),
  },
};

describe('SettingPageContent', () =>
  testComponentSnapshotsWithFixtures(SettingsPageContent, fixtures));
