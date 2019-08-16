import PermissionDenied from '.';
import { testComponentSnapshotsWithFixtures } from '../../common/testHelpers';

const fixtures = {
  'should render with default props': {},
  'should render with custom props': {
    backHref: '/home/dashboard',
    texts: {
      notAuthorizedMsg: 'notAuthorizedMsg',
      pleaseRequestMsg: 'pleaseRequestMsg',
      permissionDeniedMsg: 'permissionDeniedMsg',
    },
  },
};

describe('PermissionDenied', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(PermissionDenied, fixtures);
  });
});
