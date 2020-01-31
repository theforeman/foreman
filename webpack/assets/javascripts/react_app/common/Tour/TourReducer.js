import Immutable from 'seamless-immutable';

import {
  TOUR_UPDATE_STATUS,
  TOUR_GET_STATUSES,
  TOUR_START_RUNNING,
  TOUR_STOP_RUNNING,
  TOUR_REGISTER,
  TOURS_REQUESTS,
} from './TourConstants';

const initialState = Immutable({});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    // eslint-disable-next-line no-case-declarations
    case TOUR_UPDATE_STATUS:
      return state
        .setIn([payload.id, 'alreadySeen'], true)
        .setIn([payload.id, 'running'], false);

    case TOURS_REQUESTS:
      return state.set('loadingTour', true);

    case TOUR_GET_STATUSES:
      return state.merge({ ...payload, loadingTour: false });

    case TOUR_START_RUNNING:
      return state.setIn([payload.id, 'running'], true);

    case TOUR_STOP_RUNNING:
      return state.setIn([payload.id, 'running'], false);

    case TOUR_REGISTER:
      return state.set(payload.id, { running: false, alreadySeen: false });

    default:
      return state;
  }
};
