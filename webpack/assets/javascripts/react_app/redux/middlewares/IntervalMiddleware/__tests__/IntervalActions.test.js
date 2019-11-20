import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import { stopInterval, startIntervalAction } from '../IntervalActions';
import { key, intervalID } from '../IntervalFixtures';

const fixtures = {
  'should start interval': () => startIntervalAction(key, intervalID),
  'should stop interval': () => stopInterval(key),
};

describe('Interval actions', () => testActionSnapshotWithFixtures(fixtures));
