export const selectDebounce = state => state.debounce || {};

export const selectDebounceItem = (state, key) => selectDebounce(state)[key];
