import { selectComponentByWeight } from '../components/common/Slot/SlotSelectors';

export const selectRouter = state => state.router;
export const selectRouterLocation = state => selectRouter(state).location;
export const selectRouterPath = state => selectRouterLocation(state).pathname;
export const selectRouterSearch = state => selectRouterLocation(state).search;
export const selectRouterHash = state => selectRouterLocation(state).hash;
export const selectLastHistoryAction = state => selectRouter(state).action;
export const selectRoutes = coreRoutes =>
  coreRoutes.concat(selectComponentByWeight('routes'));
