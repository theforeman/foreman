import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import { stopInterval, startInterval } from '../IntervalActions';
import { key, intervalID } from '../IntervalFixtures';

const fixtures = {
  'should start interval': () => startInterval(key, intervalID),
  'should stop interval': () => stopInterval(key),
};

describe('Interval actions', () => testActionSnapshotWithFixtures(fixtures));
