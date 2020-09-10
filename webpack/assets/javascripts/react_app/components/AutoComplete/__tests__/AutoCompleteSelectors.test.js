import {
  selectAutocompleteSearchQuery,
  selectAutocompleteStatus,
  selectAutocompleteController,
  selectAutocompleteTrigger,
  selectAutocompleteUrl,
  selectAutocompleteIsDisabled,
  selectAutocompleteError,
  selectAutocompleteResults,
} from '../AutoCompleteSelectors';
import {
  searchQuery,
  status,
  url,
  isDisabled,
  controller,
  trigger,
  id,
  error,
  results,
  isErrorVisible,
} from '../AutoComplete.fixtures';
import { TRIGGERS } from '../AutoCompleteConstants';

describe('Autocomplete Selector', () => {
  const state = {
    autocomplete: {
      [id]: {
        searchQuery,
        status,
        url,
        isDisabled,
        controller,
        trigger,
        error,
        isErrorVisible,
        results,
      },
    },
  };

  const emptyState = { autocomplete: {} };

  const ownProps = {
    searchQuery,
    status,
    url,
    isDisabled,
    controller,
    trigger,
  };

  it('should select searchQuery', () => {
    expect(selectAutocompleteSearchQuery(state, id)).toEqual(searchQuery);
  });

  it('should select status', () => {
    expect(selectAutocompleteStatus(state, id)).toEqual(status);
  });

  it('should select controller', () => {
    expect(selectAutocompleteController(state, id)).toEqual(controller);
  });

  it('should select trigger', () => {
    expect(selectAutocompleteTrigger(state, id)).toEqual(trigger);
  });

  it('should select url', () => {
    expect(selectAutocompleteUrl(state, id)).toEqual(url);
  });

  it('should select isDisabled', () => {
    expect(selectAutocompleteIsDisabled(state, id)).toEqual(isDisabled);
  });

  it('should select error', () => {
    const modifiedState = { ...state };
    modifiedState.autocomplete[id].isErrorVisible = true;
    expect(selectAutocompleteError(modifiedState, id)).toEqual(error);
  });

  it('should select results', () => {
    expect(selectAutocompleteResults(state, id)).toEqual(results);
  });

  it('should select searchQuery from ownProps when autocomplete is not initiated yet', () => {
    expect(selectAutocompleteSearchQuery(emptyState, id, ownProps)).toEqual(
      searchQuery
    );
  });

  it('should select searchQuery from state when autocomplete is initiated', () => {
    const query = 'some-special-query';
    const props = { ...ownProps, searchQuery: query };
    expect(selectAutocompleteSearchQuery(state, id, props)).toEqual(
      searchQuery
    );
  });

  it('should select searchQuery from ownProps when autocomplete is initiated but last trigger was "RESET"', () => {
    const query = 'some-special-query';
    const modifiedState = { ...state };
    modifiedState.autocomplete[id].trigger = TRIGGERS.RESET;
    const props = { ...ownProps, searchQuery: query };
    expect(selectAutocompleteSearchQuery(modifiedState, id, props)).toEqual(
      query
    );
  });
});
