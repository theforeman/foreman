import store from './react_app/redux';
import {
  getResults,
  resetData,
  updateDisability,
} from './react_app/components/AutoComplete/AutoCompleteActions';

export {
  TRIGGERS,
} from './react_app/components/AutoComplete/AutoCompleteConstants';

export const updateController = ({ url, controller, id, trigger }) => {
  store.dispatch(resetData({ controller, id }));
  store.dispatch(
    getResults({
      trigger,
      url,
      controller,
      searchQuery: '',
      id,
    })
  );
};

export const disableAutocomplete = autocompleteID =>
  store.dispatch(updateDisability(true, autocompleteID));

export const enableAutocomplete = autocompleteID =>
  store.dispatch(updateDisability(false, autocompleteID));
