import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import SettingValueField from './SettingValueField';

import { settings } from '../../__tests__/SettingsPage.fixtures';

const props = {
  form: {},
  field: {},
};

const fixtures = {
  'should render for string setting': {
    setting: { name: 'setting', value: 'foo' },
    initialValues: { value: 'foo' },
    ...props,
  },
  'should render for boolean setting': {
    setting: settings.find(
      item => item.name === 'always_show_configuration_status'
    ),
    initialValues: { value: false },
    ...props,
  },
  'should render for array setting': {
    setting: settings.find(item => item.name === 'http_proxy_except_list'),
    initialValues: { value: ['localhost'] },
    ...props,
  },
  'should render for setting with grouped selection': {
    setting: settings.find(item => item.name === 'host_owner'),
    initialValues: { value: '13-Users' },
    ...props,
  },
  'should render for setting with simple selection': {
    setting: settings.find(item => item.name === 'global_PXELinux'),
    initialValues: { value: 'CoreOS PXELinux' },
    ...props,
  },
};

describe('SettingValueField', () =>
  testComponentSnapshotsWithFixtures(SettingValueField, fixtures));
