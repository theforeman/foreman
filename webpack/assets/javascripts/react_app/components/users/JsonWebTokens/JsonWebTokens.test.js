import { STATUS } from '../../../constants';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import Generate from './components/Generate';
import Info from './components/Info';
import Invalidate from './components/Invalidate';
import Token from './components/Token';

export const generateProps = {
  handleSubmit: () => {},
  modalActions: {
    setModalOpen: () => {},
    setModalClosed: () => {},
  },
  expiresAt: new Date(),
  setExpiresAt: () => {},
}
export const invalidateProps = {
  handleSubmit: () => {},
  modalActions: {
    setModalOpen: () => {},
    setModalClosed: () => {},
  },
}

export const tokenProps = {
  status: STATUS.RESOLVED,
  token: 'token-value'
}

describe('JsonWebTokens', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(Generate, {'renders Generate': generateProps});
    testComponentSnapshotsWithFixtures(Info, {'renders Info': {}});
    testComponentSnapshotsWithFixtures(Invalidate, {'renders Invalidate': invalidateProps});
    testComponentSnapshotsWithFixtures(Token, {'renders Token': tokenProps});
  });
});
