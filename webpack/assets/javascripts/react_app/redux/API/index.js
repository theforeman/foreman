import apiReducer from './APIReducer';

export const reducers = { API: apiReducer };

export { actionTypeGenerator } from './APIActionTypeGenerator';
export { API_OPERATIONS } from './APIConstants';
export { APIMiddleware } from './APIMiddleware';
export { default as API } from './API';
export * from './APIActions';
