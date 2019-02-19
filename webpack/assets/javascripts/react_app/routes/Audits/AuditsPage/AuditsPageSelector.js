import {
  AUDITS_NEXT,
  AUDITS_CURRENT,
  AUDITS_PREV,
} from './AuditsPageConstants';

export const selectAuditsPage = state => state.auditsPage;

export const selectAudits = state => selectAuditsPage(state)[AUDITS_CURRENT];
export const selectNextPageAudits = state =>
  selectAuditsPage(state)[AUDITS_NEXT];
export const selectPrevPageAudits = state =>
  selectAuditsPage(state)[AUDITS_PREV];

export const selectAuditsIsLoading = state => selectAuditsPage(state).isLoading;
export const selectAuditsSelectedPage = state => selectAuditsPage(state).page;
export const selectAuditsPerPage = state => selectAuditsPage(state).perPage;
export const selectAuditsCount = state => selectAuditsPage(state).itemCount;
export const selectAuditsMessage = state => selectAuditsPage(state).message;
export const selectAuditsSearch = state => selectAuditsPage(state).searchQuery;
export const selectAuditsShowMessage = state =>
  selectAuditsPage(state).showMessage;
export const selectAuditsIsFetchingNext = state =>
  selectAuditsPage(state).isFetchingNext;
export const selectAuditsIsFetchingPrev = state =>
  selectAuditsPage(state).isFetchingPrev;
