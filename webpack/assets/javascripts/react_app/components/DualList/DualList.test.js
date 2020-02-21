import { testComponentSnapshotsWithFixtures } from '../../common/testHelpers';
import DualList from './DualList';
import { props } from './DualList.fixtures';

const fixtures = {
  'renders DualList': props,
};

describe('DualList', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(DualList, fixtures));
});
