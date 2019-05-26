import { APP_FETCH_SERVER_PROPS } from './ReactAppConstants';

export const initializeMetadata = metadata => ({
  type: APP_FETCH_SERVER_PROPS,
  payload: metadata,
});
