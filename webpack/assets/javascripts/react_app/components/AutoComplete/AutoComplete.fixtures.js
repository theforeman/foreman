import { STATUS } from '../../constants';
import { TRIGGERS } from './AutoCompleteConstants';

export const url = 'models/auto_complete_search?search=';
export const status = null;
export const controller = 'models';
export const searchQuery = '';
export const initialQuery = '';
export const trigger = TRIGGERS.INPUT_CHANGE;
export const error = 'oops';
export const results = [{ label: 'some results', category: 'category' }];
export const APIError = [{ error }];
export const APISuccessMock = { data: results };
export const APIFailMock = { data: APIError };
export const id = 'search-input';
export const isDisabled = false;

export const AutoCompleteProps = {
  controller,
  searchQuery,
  initialQuery,
  status,
  results,
  initialUrl: url,
  id,
  isDisabled,
};

export const initialState = {
  controller: null,
  error: null,
  results: [],
  searchQuery: '',
  status: null,
  trigger: null,
  url: null,
  id,
  isDisabled,
};

export const initialValues = {
  searchQuery,
  controller,
  trigger: TRIGGERS.COMPONENT_DID_MOUNT,
  results,
  status: STATUS.RESOLVED,
  url: undefined,
  id,
  isDisabled,
};

export const request = {
  controller,
  error: null,
  searchQuery,
  status: STATUS.PENDING,
  trigger,
  id,
};

export const success = {
  error: null,
  results,
  status: STATUS.RESOLVED,
  searchQuery,
  controller,
  trigger,
  url,
  id,
  isDisabled,
};

export const failure = {
  error,
  results: [],
  status: STATUS.ERROR,
  id,
};

export const disabledChange = {
  isDisabled: true,
  id,
};
