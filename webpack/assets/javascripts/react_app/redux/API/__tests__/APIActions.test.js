import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import { startPolling, stopPolling } from '../APIActions';
import { key, APIRequest, polling } from '../APIFixtures';

const fixtures = {
  'should start polling': () => startPolling(key, APIRequest, polling),
  'should stop polling': () => stopPolling(key),
};

describe('API actions', () => testActionSnapshotWithFixtures(fixtures));
