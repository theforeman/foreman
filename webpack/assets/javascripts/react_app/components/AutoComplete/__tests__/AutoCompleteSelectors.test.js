import {
  selectAutocompleteSearchQuery,
  selectAutocompleteStatus,
  selectAutocompleteController,
  selectAutocompleteTrigger,
} from '../AutoCompleteSelectors';
import {
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
      searchQuery,
      status,
      url,
      isDisabled,
      controller,
      trigger,
    },
  };

  it('should select searchQuery', () => {
    expect(selectAutocompleteSearchQuery(state)).toEqual(searchQuery);
  });

  it('should select status', () => {
    expect(selectAutocompleteStatus(state)).toEqual(status);
  });

  it('should select controller', () => {
    expect(selectAutocompleteController(state)).toEqual(controller);
  });

  it('should select trigger', () => {
    expect(selectAutocompleteTrigger(state)).toEqual(trigger);
  });
});
