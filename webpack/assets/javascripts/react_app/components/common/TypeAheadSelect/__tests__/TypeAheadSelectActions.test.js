import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import {
  initialUpdate,
  updateOptions,
  updateSelected,
} from '../TypeAheadSelectActions';
import { id, options, selected } from '../TypeAheadSelect.fixtures';

const fixtures = {
  'initializes defaults': () => initialUpdate(options, selected, id),
  'updates options': () => updateOptions(options, id),
  'updates selections': () => updateSelected(selected, id),
};

describe('TypeAheadSelectActions', () =>
  testActionSnapshotWithFixtures(fixtures));
