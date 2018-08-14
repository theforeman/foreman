import {
  selectIsRunning,
  selectIsAlreadySeen,
  selectTours,
  selectActiveTour,
} from '../TourSelectors';
import { testSelectorsSnapshotWithFixtures } from '../../../common/testHelpers';

const state = {
  tours: {
    tour_1: { alreadySeen: false, running: true },
    tour_2: { alreadySeen: true, running: false },
    tour_3: { alreadySeen: false, running: true },
  },
};

const fixtures = {
  'should return all tours': () => selectTours(state),
  "should return tour's running state": () => selectIsRunning(state, 'tour_1'),
  "should return tour's seen state": () => selectIsAlreadySeen(state, 'tour_2'),
  'should return the active tour': () => selectActiveTour(state),
};

describe('Layout selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
