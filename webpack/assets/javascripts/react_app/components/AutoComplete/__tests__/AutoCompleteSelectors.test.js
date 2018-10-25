import {
  selectAutocompleteSearchQuery,
  selectAutocompleteStatus,
  selectAutocompleteUrl,
  selectAutocompleteIsDisabled,
  selectAutocompleteController,
  selectAutocompleteTrigger,
} from '../AutoCompleteSelectors';
import {
  id,
  searchQuery,
  status,
  url,
  isDisabled,
  controller,
  trigger,
} from '../AutoComplete.fixtures';

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
      },
    },
  };

  it('should select searchQuery', () => {
    expect(selectAutocompleteSearchQuery(state, id)).toEqual(searchQuery);
  });

  it('should select status', () => {
    expect(selectAutocompleteStatus(state, id)).toEqual(status);
  });

  it('should select url', () => {
    expect(selectAutocompleteUrl(state, id)).toEqual(url);
  });

  it('should select isDisabled', () => {
    expect(selectAutocompleteIsDisabled(state, id)).toEqual(isDisabled);
  });

  it('should select controller', () => {
    expect(selectAutocompleteController(state, id)).toEqual(controller);
  });

  it('should select trigger', () => {
    expect(selectAutocompleteTrigger(state, id)).toEqual(trigger);
  });
});
