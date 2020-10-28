import {
  selectAPIErrorMessage,
  selectAPIResponse,
} from '../../../redux/API/APISelectors';
import { AUTH_SOURCES_TABLE_KEY } from './AuthSourcesConstants';

const selectErrorMessage = (state, key) => selectAPIErrorMessage(state, key);

const selectStateFromAPI = (state, key) => selectAPIResponse(state, key).state;

const selectTitleFromAPI = (state, key) => selectAPIResponse(state, key).title;

export const selectAuthSource = state => state.authsources || {};

export const selectResults = state => {
  const { results } = selectAPIResponse(state, AUTH_SOURCES_TABLE_KEY);
  return (results && results.asMutable()) || [];
};
