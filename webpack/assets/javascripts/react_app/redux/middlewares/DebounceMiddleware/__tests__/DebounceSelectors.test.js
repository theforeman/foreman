import { testSelectorsSnapshotWithFixtures } from '@theforeman/test';
import { key, stateWithKey } from '../DebounceFixtures';
import { selectDebounce, selectDebounceItem } from '../DebounceSelectors';

const state = {
  debounce: stateWithKey,
};

const fixtures = {
  'should return the debounce wrapper': () => selectDebounce(state),
  'should return the debounce item': () => selectDebounceItem(state, key),
};

describe('intervals selectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
