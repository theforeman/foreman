import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

import CopyToClipboard from '../CopyToClipboard';

const fixtures = {
  ok: {
    valueToCopy: 'Some value to copy!',
  },
};

describe('CopyToClipboard', () => {
  testComponentSnapshotsWithFixtures(CopyToClipboard, fixtures);
});
