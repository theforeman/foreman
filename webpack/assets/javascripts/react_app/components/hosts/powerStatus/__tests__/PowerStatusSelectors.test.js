import { testSelectorsSnapshotWithFixtures } from '../../../../common/testHelpers';
import { selectState, selectTitle } from '../PowerStatusSelectors';
import { resolvedStore, errorStore, key } from '../PowerStatus.fixtures';

const fixtures = {
  'should return a power status state': () => selectState(resolvedStore, key),
  'should return n/a state on error': () => selectState(errorStore, key),
  'should return a power status title': () => selectTitle(resolvedStore, key),
  'should return a different title on error': () =>
    selectTitle(errorStore, key),
};

describe('Power status selectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
