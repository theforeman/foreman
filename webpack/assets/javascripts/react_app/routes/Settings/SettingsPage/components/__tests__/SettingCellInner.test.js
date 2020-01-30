import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import SettingCellInner from '../SettingCellInner';

const onEditClick = () => {};

const fixtures = {
  'should render setting with empty value': {
    setting: { name: 'setting', value: '', default: '' },
    onEditClick,
  },
  'should render setting with changed default': {
    setting: { name: 'setting', value: 'foo', default: 'bar' },
    onEditClick,
  },
  'should render setting with default value ': {
    setting: { name: 'setting', value: 'foo', default: 'foo' },
    onEditClick,
  },
};

describe('SettingCellInner', () =>
  testComponentSnapshotsWithFixtures(SettingCellInner, fixtures));
