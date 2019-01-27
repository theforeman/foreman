export const selectAuditsPage = state => state.auditsPage;

export const selectAudits = state => selectAuditsPage(state).audits;
export const selectAuditsSelectedPage = state => selectAuditsPage(state).page;
export const selectAuditsPerPage = state => selectAuditsPage(state).perPage;
export const selectAuditsCount = state => selectAuditsPage(state).itemCount;
export const selectAuditsMessage = state => selectAuditsPage(state).message;
export const selectAuditsShowMessage = state =>
  selectAuditsPage(state).showMessage;
