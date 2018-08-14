import API from '../../API';
import {
  TOUR_UPDATE_STATUS,
  TOUR_GET_STATUSES,
  TOUR_START_RUNNIG,
  TOUR_STOP_RUNNING,
  TOUR_REGISTER,
} from './TourConstants';

export const updateAsSeen = id => dispatch =>
  API.post('/user_preferences', {
    kind: 'Tour',
    value: { alreadySeen: true },
    name: id,
  }).then(() =>
    dispatch({
      type: TOUR_UPDATE_STATUS,
      payload: { id },
    })
  );

export const getTours = () => dispatch =>
  API.get('/user_preferences?search=kind=Tour').then(({ data }) =>
    dispatch({
      type: TOUR_GET_STATUSES,
      payload: data,
    })
  );

export const startRunnig = id => ({ type: TOUR_START_RUNNIG, payload: { id } });

export const registerTour = id => ({ type: TOUR_REGISTER, payload: { id } });

export const stopRunning = id => dispatch => {
  sessionStorage.setItem(`TOUR_${id}`, true);
  return dispatch({
    type: TOUR_STOP_RUNNING,
    payload: { id },
  });
};
