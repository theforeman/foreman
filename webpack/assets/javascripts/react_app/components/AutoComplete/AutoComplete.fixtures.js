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

export const AutoCompleteProps = {
  controller,
  searchQuery,
  initialQuery,
  status,
  results,
  url,
};

export const initialState = {
  controller: null,
  error: null,
  results: [],
  searchQuery: '',
  status: null,
  trigger: null,
};

export const initialValues = {
  searchQuery,
  controller,
  trigger: TRIGGERS.COMPONENT_DID_MOUNT,
  results,
  status: STATUS.RESOLVED,
};

export const request = {
  controller,
  error: null,
  searchQuery,
  status: STATUS.PENDING,
  trigger,
};

export const success = {
  error: null,
  results,
  status: STATUS.RESOLVED,
  searchQuery,
  controller,
  trigger,
};

export const failure = {
  error,
  results: [],
  status: STATUS.ERROR,
};
