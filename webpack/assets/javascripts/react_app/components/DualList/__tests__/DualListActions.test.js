import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import { initialUpdate, onChange } from '../DualListActions';
import { selectedItems, id } from '../DualList.fixtures';

const fixtures = {
  'should update store with initial data': () =>
    initialUpdate(selectedItems, id),

  'should update store on change between the selectors': () =>
    onChange(selectedItems, id),
};

describe('DualList actions', () => testActionSnapshotWithFixtures(fixtures));
