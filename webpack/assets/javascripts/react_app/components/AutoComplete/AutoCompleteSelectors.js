export const selectAutocomplete = (state, id) => state.autocomplete[id] || {};

export const selectAutocompleteError = (state, id) =>
  selectAutocomplete(state, id).error;

export const selectAutocompleteResults = (state, id) =>
  selectAutocomplete(state, id).results;

export const selectAutocompleteSearchQuery = (state, id) =>
  selectAutocomplete(state, id).searchQuery;

export const selectAutocompleteStatus = (state, id) =>
  selectAutocomplete(state, id).status;

export const selectAutocompleteUrl = (state, id) =>
  selectAutocomplete(state, id).url;

export const selectAutocompleteIsDisabled = (state, id) =>
  selectAutocomplete(state, id).isDisabled;

export const selectAutocompleteController = (state, id) =>
  selectAutocomplete(state, id).controller;

export const selectAutocompleteTrigger = (state, id) =>
  selectAutocomplete(state, id).trigger;
