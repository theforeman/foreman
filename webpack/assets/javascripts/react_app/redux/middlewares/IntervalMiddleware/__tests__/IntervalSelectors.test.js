import { testSelectorsSnapshotWithFixtures } from '../../../../common/testHelpers';
import { selectIntervals, selectIntervalID } from '../IntervalSelectors';
import { key, stateWithKey } from '../IntervalFixtures';

const state = {
  intervals: stateWithKey,
};

const fixtures = {
  'should return the intervals wrapper': () => selectIntervals(state),
  'should return the interval ID': () => selectIntervalID(state, key),
};

describe('intervals selectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
