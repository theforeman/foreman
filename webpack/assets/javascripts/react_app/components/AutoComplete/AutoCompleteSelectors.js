export const selectAutocomplete = ({ autocomplete }, id) =>
  autocomplete[id] || {};

export const selectAutocompleteIsErrorVisible = (state, id) =>
  selectAutocomplete(state, id).isErrorVisible;

export const selectAutocompleteError = (state, id) => {
  const { error, isErrorVisible } = selectAutocomplete(state, id);
  return error && isErrorVisible ? error : null;
};

export const selectAutocompleteResults = (state, id) =>
  selectAutocomplete(state, id).results;

export const selectAutocompleteSearchQuery = (state, id) =>
  selectAutocomplete(state, id).searchQuery;

export const selectAutocompleteStatus = (state, id) =>
  selectAutocomplete(state, id).status;

export const selectAutocompleteController = (state, id) =>
  selectAutocomplete(state, id).controller;

export const selectAutocompleteTrigger = (state, id) =>
  selectAutocomplete(state, id).trigger;
