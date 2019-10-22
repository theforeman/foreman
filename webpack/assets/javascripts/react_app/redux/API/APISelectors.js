export const selectAPIOperations = state => state.API_operations || {};
export const selectPolling = state => selectAPIOperations(state).polling || {};
export const selectPollingID = (state, key) => selectPolling(state)[key];
