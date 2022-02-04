export const selectBreadcrumbBar = state => state.breadcrumbBar;
export const selectResourceSwitcherItems = state =>
  selectBreadcrumbBar(state).resourceSwitcherItems;
export const selectResourceUrl = state =>
  selectBreadcrumbBar(state).resourceUrl;
export const selectIsSwitcherOpen = state =>
  selectBreadcrumbBar(state).isSwitcherOpen;
export const selectIsLoadingResources = state =>
  selectBreadcrumbBar(state).isLoadingResources;
export const selectHasError = state =>
  selectBreadcrumbBar(state).requestError != null;
export const selectCurrentPage = state =>
  selectBreadcrumbBar(state).currentPage;
export const selectTotal = state => selectBreadcrumbBar(state).total;
export const selectSearchQuery = state =>
  selectBreadcrumbBar(state).searchQuery;
export const selectRemoveSearchQuery = state =>
  selectBreadcrumbBar(state).removeSearchQuery;
export const selectTitleReplacement = state =>
  selectBreadcrumbBar(state).titleReplacement;
export const selectPerPage = state => selectBreadcrumbBar(state).perPage;
