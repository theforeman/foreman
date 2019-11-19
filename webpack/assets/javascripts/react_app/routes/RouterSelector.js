export const selectRouterLocation = state => state.router.location;
export const selectRouterPath = state => selectRouterLocation(state).pathname;
export const selectRouterSearch = state => selectRouterLocation(state).search;
export const selectRouterHash = state => selectRouterLocation(state).hash;
export const SelectLastHistoryAction = state => state.router.action;
