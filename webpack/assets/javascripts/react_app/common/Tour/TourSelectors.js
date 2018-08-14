import { createSelector } from 'reselect';
import { get } from 'lodash';

export const selectTours = state => state.tours;

export const selectActiveTour = createSelector(
  selectTours,
  tours => tours && Object.entries(tours).filter(tour => tour[1].running)[0]
);

export const selectIsAlreadySeen = (state, id) =>
  get(state, `tours.${id}.alreadySeen`);

export const selectIsRunning = (state, id) => get(state, `tours.${id}.running`);

export const selectLoadingState = state => selectTours(state).loadingTour;
const selectSessionStorage = (state, id) =>
  sessionStorage.getItem(`TOUR_${id}`);
export const selectIfRendering = (state, id) =>
  selectIsAlreadySeen(state, id) || selectSessionStorage(state, id);
