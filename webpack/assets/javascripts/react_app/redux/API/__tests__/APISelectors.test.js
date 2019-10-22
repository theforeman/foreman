import { testSelectorsSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  selectAPIOperations,
  selectPolling,
  selectPollingID,
} from '../APISelectors';
import { key, stateWithKey } from '../APIFixtures';

const state = {
  API_operations: stateWithKey,
};

const fixtures = {
  'should return API_operations': () => selectAPIOperations(state),
  'should return the polling processes wrapper': () => selectPolling(state),
  'should return a polling ID': () => selectPollingID(state, key),
};

describe('API selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
