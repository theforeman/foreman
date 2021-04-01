import { testSelectorsSnapshotWithFixtures } from '../../common/testHelpers';
import { get } from 'lodash';
import { HOST_STATUSES_KEY } from './HostStatusesConstants';
import {
  selectHostStatusesNames,
  selectGlobalStatus,
  selectHostStatusDetails,
  selectHostStatusDescription,
  selectHostStatusCounter,
  selectHostStatusTotalPaths,
  selectHostStatusOwnedPaths
} from './HostStatusesSelectors';
import { store } from './HostStatuses.fixtures.js'

const statusName = get(store, ['API', HOST_STATUSES_KEY, 'response', 'results', '0', 'name']);

const fixtures = {
  'selects HostStatusesNames': () => selectHostStatusesNames(store),
  'selects HostStatusDetails': () => selectHostStatusDetails(store, statusName),
  'selects HostStatusDescription': () => selectHostStatusDescription(store, statusName),
  'selects selectHostStatusTotalPaths': () => selectHostStatusTotalPaths(store, statusName),
  'selects selectHostStatusOwnedPaths': () => selectHostStatusOwnedPaths(store, statusName),
  'selects GlobalStatus': () => selectGlobalStatus(store, statusName),
  'selects HostStatusCounter': () => selectHostStatusCounter(store, statusName)
};

describe('HostStatusesSelectors selectors', () => {
  testSelectorsSnapshotWithFixtures(fixtures);
});
