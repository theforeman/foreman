import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import { startInterval, stopInterval } from '../IntervalActions';
import { key, callback, interval } from '../IntervalFixtures';

const fixtures = {
  'should start interval': () => startInterval(key, callback, interval),
  'should stop interval': () => stopInterval(key),
};

describe('API actions', () => testActionSnapshotWithFixtures(fixtures));
