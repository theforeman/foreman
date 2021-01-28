import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import { arraySetting } from '../SettingRecords/__tests__/SettingRecords.fixtures';

import SettingUpdateModal from './SettingUpdateModal';

const fixtures = {
  'it should render': {
    setting: arraySetting,
    setModalClosed: () => {},
  },
};

describe('SettingUpdateModal', () =>
  testComponentSnapshotsWithFixtures(SettingUpdateModal, fixtures));
