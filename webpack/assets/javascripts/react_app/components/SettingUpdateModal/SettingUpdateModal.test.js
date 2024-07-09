import { testComponentSnapshotsWithFixtures } from 'foremanReact/common/testHelpers';

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
