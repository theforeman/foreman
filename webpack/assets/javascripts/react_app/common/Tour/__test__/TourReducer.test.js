import {
  TOUR_UPDATE_STATUS,
  TOUR_GET_STATUSES,
  TOUR_START_RUNNIG,
  TOUR_STOP_RUNNING,
  TOUR_REGISTER,
} from '../TourConstants';

import reducer from '../TourReducer';

import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'should return the initial state': {},
  'should update state with initial data': {
    action: {
      type: TOUR_REGISTER,
      payload: { id: 'Tour_1' },
    },
  },
  'should handle TOUR_START_RUNNIG': {
    action: {
      type: TOUR_START_RUNNIG,
      payload: { id: 'Tour_1' },
    },
  },
  'should handle TOUR_STOP_RUNNING': {
    action: {
      type: TOUR_STOP_RUNNING,
      payload: { id: 'Tour_1' },
    },
  },
  'should handle TOUR_UPDATE_STATUS': {
    action: {
      type: TOUR_UPDATE_STATUS,
      payload: { id: 'Tour_1' },
    },
  },
  'should handle TOUR_GET_STATUSES': {
    action: {
      type: TOUR_GET_STATUSES,
      payload: {
        Tour_1: { alreadySeen: true },
        Tour_2: { alreadySeen: true },
      },
    },
  },
};

describe('Tour reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
