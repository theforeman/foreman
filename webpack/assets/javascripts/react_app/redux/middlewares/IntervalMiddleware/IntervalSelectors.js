export const selectIntervals = state => state.intervals || {};
export const selectIntervalID = (state, key) => selectIntervals(state)[key];
export const selectIsIntervalExists = (state, key) =>
  !!selectIntervals(state)[key];
