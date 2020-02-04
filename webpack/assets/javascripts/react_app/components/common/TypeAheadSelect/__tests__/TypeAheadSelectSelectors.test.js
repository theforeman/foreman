import {
  selectSelected,
  selectOptions,
  selectTypeAheadSelectExists,
} from '../TypeAheadSelectSelectors';
import { id, initialState, populatedState } from '../TypeAheadSelect.fixtures';
import { testSelectorsSnapshotWithFixtures } from '../../../../common/testHelpers';

describe('TypeAheadSelectSelectors', () => {
  describe('with empty state', () => {
    const fixtures = {
      'returns an nothing': () => selectSelected(initialState, id),
      'returns an empty array of options': () =>
        selectOptions(initialState, id),
      'returns false': () => selectTypeAheadSelectExists(initialState, id),
    };

    testSelectorsSnapshotWithFixtures(fixtures);
  });

  describe('with state', () => {
    const fixtures = {
      'returns selections array from state': () =>
        selectSelected(populatedState, id),
      'returns options array from state': () =>
        selectOptions(populatedState, id),
      'returns true': () => selectTypeAheadSelectExists(populatedState, id),
    };

    testSelectorsSnapshotWithFixtures(fixtures);
  });
});
