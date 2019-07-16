import { APP_FETCH_SERVER_PROPS, I18N_READY } from './ReactAppConstants';

export const initializeMetadata = metadata => ({
  type: APP_FETCH_SERVER_PROPS,
  payload: metadata,
});

export const i18nReady = () => ({ type: I18N_READY });
