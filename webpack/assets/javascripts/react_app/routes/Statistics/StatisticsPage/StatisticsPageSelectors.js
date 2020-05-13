export const selectStatisticsPage = state => state.statisticsPage;

export const selectStatisticsMetadata = state =>
  selectStatisticsPage(state).metadata;
export const selectStatisticsDiscussionUrl = state =>
  selectStatisticsPage(state).discussionUrl;
export const selectStatisticsIsLoading = state =>
  selectStatisticsPage(state).isLoading;
export const selectStatisticsMessage = state =>
  selectStatisticsPage(state).message;
export const selectStatisticsHasError = state =>
  selectStatisticsPage(state).hasError;
export const selectStatisticsHasMetadata = state =>
  selectStatisticsPage(state).hasData;
