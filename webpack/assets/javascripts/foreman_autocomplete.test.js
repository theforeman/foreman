import store from './react_app/redux';
import {
  updateController,
  disableAutocomplete,
  enableAutocomplete,
} from './foreman_autocomplete';
import {
  getResults,
  resetData,
  updateDisability,
} from './react_app/components/AutoComplete/AutoCompleteActions';
import { TRIGGERS } from './react_app/components/AutoComplete/AutoCompleteConstants';

jest.unmock('./foreman_autocomplete');
jest.mock('./react_app/redux', () => ({ dispatch: jest.fn() }));
jest.mock('./react_app/components/AutoComplete/AutoCompleteActions');

const fixtures = {
  url: 'some-url',
  controller: 'some-controller',
  id: 'some-id',
  trigger: TRIGGERS.RESOURCE_TYPE_CHANGED,
  searchQuery: '',
  isDisabled: false,
};
describe('foreman_autocomplete', () => {
  beforeEach(() => jest.resetAllMocks());

  describe('updateController', () => {
    it('should dispatch two actions', () => {
      const { url, controller, id, trigger, searchQuery } = fixtures;
      updateController({ url, controller, id, trigger });
      expect(resetData).toHaveBeenCalledWith({ controller, id });
      expect(getResults).toHaveBeenCalledWith({
        trigger,
        url,
        controller,
        searchQuery,
        id,
      });
      expect(store.dispatch).toHaveBeenCalledTimes(2);
    });
  });

  describe('disableAutocomplete', () => {
    it('should dispatch an action', () => {
      const { id } = fixtures;
      disableAutocomplete(id);
      expect(updateDisability).toHaveBeenCalledWith(true, id);
      expect(store.dispatch).toHaveBeenCalledTimes(1);
    });
  });

  describe('enableAutocomplete', () => {
    it('should dispatch an action', () => {
      const { id } = fixtures;
      enableAutocomplete(id);
      expect(updateDisability).toHaveBeenCalledWith(false, id);
      expect(store.dispatch).toHaveBeenCalledTimes(1);
    });
  });
});
