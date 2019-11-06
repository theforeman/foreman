import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import { startInterval, stopInterval } from '../IntervalActions';
import { key, method, interval } from '../IntervalFixtures';

const fixtures = {
  'should start interval': () => startInterval(key, method, interval),
  'should stop interval': () => stopInterval(key),
};

describe('API actions', () => testActionSnapshotWithFixtures(fixtures));
