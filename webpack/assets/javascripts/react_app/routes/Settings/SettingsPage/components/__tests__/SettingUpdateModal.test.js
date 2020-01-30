import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import SettingUpdateModal from '../SettingUpdateModal';

const fixtures = {
  'should render': {
    setting: { fullName: 'test setting' },
    setModalClosed: () => {},
  },
};

describe('SettingUpdateModal', () =>
  testComponentSnapshotsWithFixtures(SettingUpdateModal, fixtures));
