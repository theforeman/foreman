import store from './react_app/redux';
import {
  updateController as updateAutocompleteController,
  updateDisability,
} from './react_app/components/AutoComplete/AutoCompleteActions';

export { TRIGGERS } from './react_app/components/AutoComplete/AutoCompleteConstants';

export const updateController = (controller, url, id) => {
  store.dispatch(updateAutocompleteController(controller, url, id));
};

export const disableAutocomplete = autocompleteID =>
  store.dispatch(updateDisability(true, autocompleteID));

export const enableAutocomplete = autocompleteID =>
  store.dispatch(updateDisability(false, autocompleteID));
