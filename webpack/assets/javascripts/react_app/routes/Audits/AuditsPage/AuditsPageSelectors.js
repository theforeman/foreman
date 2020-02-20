import { createSelector } from 'reselect';
import { AUDITS_MANUAL_URL } from '../constants';
import { selectReactAppVersion } from '../../../ReactApp/ReactAppSelectors';

export const selectAuditsPageData = state => state.auditsPage.data;
export const selectAuditsPageQuery = state => state.auditsPage.query;

export const selectAudits = state => selectAuditsPageData(state).audits;
export const selectAuditsMessage = state => selectAuditsPageData(state).message;
export const selectAuditsIsLoadingPage = state =>
  selectAuditsPageData(state).isLoading;
export const selectAuditsHasError = state =>
  selectAuditsPageData(state).hasError;
export const selectAuditsHasData = state => selectAuditsCount(state) > 0;

export const selectAuditsSelectedPage = state =>
  selectAuditsPageQuery(state).page;
export const selectAuditsPerPage = state =>
  selectAuditsPageQuery(state).perPage;
export const selectAuditsCount = state => selectAuditsPageData(state).itemCount;
export const selectAuditsSearch = state =>
  selectAuditsPageQuery(state).searchQuery;

export const selectAuditDocumentationUrl = createSelector(
  selectReactAppVersion,
  state => selectAuditsPageData(state).documentationUrl,
  (version, documentationUrl) => documentationUrl || AUDITS_MANUAL_URL(version)
);
