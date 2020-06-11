import { createSelector } from 'reselect';
import {
  selectAPIErrorMessage,
  selectAPIResponse,
} from '../../../redux/API/APISelectors';

const selectErrorMessage = (state, key) => selectAPIErrorMessage(state, key);

const selectStateFromAPI = (state, key) => selectAPIResponse(state, key).state;

const selectTitleFromAPI = (state, key) => selectAPIResponse(state, key).title;

const selectStatusText = (state, key) =>
  selectAPIResponse(state, key).statusText;

export const selectState = createSelector(
  selectStateFromAPI,
  selectErrorMessage,
  (state, error) => (error ? 'na' : state)
);

export const selectTitle = createSelector(
  selectTitleFromAPI,
  selectErrorMessage,
  selectStatusText,
  (title, error, statusText) => {
    if (error) {
      let errorTitle = error;
      if (title || statusText) {
        errorTitle = `${title} ${statusText}`.trim();
      }
      return errorTitle;
    }
    return statusText || title;
  }
);
