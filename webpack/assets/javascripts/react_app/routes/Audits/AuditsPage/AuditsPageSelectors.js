export const selectAuditsPageData = (state) => state.auditsPage.data;
export const selectAuditsPageQuery = (state) => state.auditsPage.query;

export const selectAudits = (state) => selectAuditsPageData(state).audits;
export const selectAuditsMessage = (state) =>
  selectAuditsPageData(state).message;
export const selectAuditsIsLoadingPage = (state) =>
  selectAuditsPageData(state).isLoading;
export const selectAuditsHasError = (state) =>
  selectAuditsPageData(state).hasError;
export const selectAuditsHasData = (state) =>
  selectAuditsPageData(state).hasData;

export const selectAuditsSelectedPage = (state) =>
  selectAuditsPageQuery(state).page;
export const selectAuditsPerPage = (state) =>
  selectAuditsPageQuery(state).perPage;
export const selectAuditsCount = (state) =>
  selectAuditsPageQuery(state).itemCount;
export const selectAuditsSearch = (state) =>
  selectAuditsPageQuery(state).searchQuery;
