import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import { wakeOnLan } from '../actions';

const fixtures = {
  'should call Wake on LAN API action': () => wakeOnLan(1, 'test-host.example.com'),
  'should call Wake on LAN API action with different host': () => wakeOnLan(42, 'another-host.example.com'),
};

describe('ActionsBar actions', () => {
  describe('wakeOnLan', () => {
    testActionSnapshotWithFixtures(fixtures);
  });
});
