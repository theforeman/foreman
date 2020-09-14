import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

import CopyToClipboard from '../';

const fixtures = {
  ok: {
    valueToCopy: 'Some value to copy!',
  },
};

describe('CopyToClipboard', () => {
  testComponentSnapshotsWithFixtures(CopyToClipboard, fixtures);
});
