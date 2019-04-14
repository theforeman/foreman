import DualList from '../DualList';
import { props } from '../DualList.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'renders DualList': props,
};
describe('DualList', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(DualList, fixtures);
  });
});
