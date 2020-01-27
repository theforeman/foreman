import {
  APP_FETCH_SERVER_PROPS,
  UPDATE_LEGACY_LOADING_STATE,
} from './ReactAppConstants';

export const initializeMetadata = metadata => ({
  type: APP_FETCH_SERVER_PROPS,
  payload: metadata,
});

export const updateLegacyLoading = state => ({
  type: UPDATE_LEGACY_LOADING_STATE,
  payload: state,
});
