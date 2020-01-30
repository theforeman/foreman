import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import TabPaneContent from '../TabPaneContent';

import { groupSettings } from '../../SettingsPageHelpers';

import { settings } from '../../__tests__/SettingsPage.fixtures';

const fixtures = {
  'should render': {
    settings: groupSettings(settings)['Setting::General'],
    onEditClick: () => {},
    category: 'Setting::General',
  },
  'should render email tab content': {
    settings: groupSettings(settings)['Setting::Email'],
    onEditClick: () => {},
    category: 'Setting::Email',
  },
};

describe('TabPaneContent', () =>
  testComponentSnapshotsWithFixtures(TabPaneContent, fixtures));
