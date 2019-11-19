export const selectRouterLocation = store => store.router.location;
export const selectRouterPath = store => selectRouterLocation(store).pathname;
export const selectRouterSearch = store => selectRouterLocation(store).search;
export const selectRouterHash = store => selectRouterLocation(store).hash;
export const lastHistoryAction = state => state.router.action;
