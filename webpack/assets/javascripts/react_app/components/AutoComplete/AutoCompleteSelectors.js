export const selectAutocomplete = state => state.autocomplete;

export const selectAutocompleteError = state => selectAutocomplete(state).error;

export const selectAutocompleteResults = state =>
  selectAutocomplete(state).results;

export const selectAutocompleteSearchQuery = state =>
  selectAutocomplete(state).searchQuery;

export const selectAutocompleteStatus = state =>
  selectAutocomplete(state).status;

export const selectAutocompleteController = state =>
  selectAutocomplete(state).controller;

export const selectAutocompleteTrigger = state =>
  selectAutocomplete(state).trigger;
