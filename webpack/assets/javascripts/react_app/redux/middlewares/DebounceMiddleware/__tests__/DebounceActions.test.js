import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import { key, debounceID, debounce, timestamp } from '../DebounceFixtures';
import {
  clearDebounce,
  startDebounce,
  stopIncomingAction,
} from '../DebounceActions';

const fixtures = {
  'should start debounce': () =>
    startDebounce({ key, debounce, debounceID, timestamp }),
  'should clear debounce': () => clearDebounce(key),
  'should inform about a canceled incoming action while debounce': () =>
    stopIncomingAction(key),
};

describe('debounce actions', () => testActionSnapshotWithFixtures(fixtures));
