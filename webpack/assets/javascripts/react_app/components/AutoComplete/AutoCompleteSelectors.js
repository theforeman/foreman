import { TRIGGERS } from './AutoCompleteConstants';

export const selectAutocomplete = ({ autocomplete }, id) => autocomplete[id];

export const selectAutocompleteProp = (state, id, prop, ownProps) => {
  const selectedAutocomplete = selectAutocomplete(state, id);
  const isAutocompleteInitiated = selectedAutocomplete !== undefined;
  const { trigger } = selectedAutocomplete || {};
  const didComponentReset = prop !== 'trigger' && trigger === TRIGGERS.RESET;
  const propFromOwnProps = ownProps && ownProps[prop];

  if (isAutocompleteInitiated) {
    if (didComponentReset) {
      return propFromOwnProps;
    }
    return selectedAutocomplete[prop];
  }
  return propFromOwnProps;
};

export const selectAutocompleteError = (state, id, ownProps) => {
  const isErrorVisible = selectAutocompleteIsErrorVisible(state, id, ownProps);
  if (!isErrorVisible) {
    return null;
  }
  return selectAutocompleteProp(state, id, 'error', ownProps);
};

export const selectAutocompleteIsErrorVisible = (state, id, ownProps) =>
  selectAutocompleteProp(state, id, 'isErrorVisible', ownProps);

export const selectAutocompleteResults = (state, id, ownProps) =>
  selectAutocompleteProp(state, id, 'results', ownProps);

export const selectAutocompleteSearchQuery = (state, id, ownProps) =>
  selectAutocompleteProp(state, id, 'searchQuery', ownProps);

export const selectAutocompleteStatus = (state, id, ownProps) =>
  selectAutocompleteProp(state, id, 'status', ownProps);

export const selectAutocompleteController = (state, id, ownProps) =>
  selectAutocompleteProp(state, id, 'controller', ownProps);

export const selectAutocompleteTrigger = (state, id, ownProps) =>
  selectAutocompleteProp(state, id, 'trigger', ownProps);

export const selectAutocompleteUrl = (state, id, ownProps) =>
  selectAutocompleteProp(state, id, 'url', ownProps);

export const selectAutocompleteIsDisabled = (state, id, ownProps) =>
  selectAutocompleteProp(state, id, 'disabled', ownProps);
