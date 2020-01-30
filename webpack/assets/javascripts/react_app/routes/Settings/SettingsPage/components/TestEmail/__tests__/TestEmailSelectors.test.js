import { testSelectorsSnapshotWithFixtures } from '@theforeman/test';

import {
  selectTestEmailState,
  selectTestEmailLoading,
} from '../TestEmailSelectors';

const state = {
  settingsPage: {
    testEmail: {
      loading: true,
    },
  },
};

const fixtures = {
  'should select email state': () => selectTestEmailState(state),
  'should select if email is being delivered': () =>
    selectTestEmailLoading(state),
};

describe('TestEmailSelectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
