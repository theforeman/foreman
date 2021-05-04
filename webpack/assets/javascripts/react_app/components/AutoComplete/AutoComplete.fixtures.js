import { STATUS } from '../../constants';
import { TRIGGERS } from './AutoCompleteConstants';

export const id = 'some-id';
export const url = 'models/auto_complete_search';
export const status = null;
export const controller = 'models';
export const searchQuery = '';
export const trigger = TRIGGERS.INPUT_CHANGE;
export const error = 'oops';
export const results = [{ label: 'some results', category: 'category' }];
export const APIError = [{ error }];
export const APISuccessMock = { data: results };
export const APIFailMock = { data: APIError };
export const isErrorVisible = false;
export const disabled = false;

export const API = {
  '': [
    { label: 'name', category: '' },
    { label: 'id', category: '' },
  ],
  n: [{ label: 'name', category: '' }],
  na: [{ label: 'name', category: '' }],
  nam: [{ label: 'name', category: '' }],
  name: [
    { label: 'name =', category: '' },
    { label: 'name ~', category: '' },
  ],
  'name+': [
    { label: 'name =', category: '' },
    { label: 'name ~', category: '' },
  ],
  'name+%3D': [{ label: 'name = foreman', category: '' }],
  'name+%3D+': [{ label: 'name = foreman', category: '' }],
  'name+~': [{ label: 'name ~ foreman', category: '' }],
  'name+~ ': [{ label: 'name ~ foreman', category: '' }],
  i: [{ label: 'id', category: '' }],
  id: [{ label: 'id', category: '' }],
  'id+%3D': [{ label: 'id = 1234', category: '' }],
  'id+%3D+': [{ label: 'id = 1234', category: '' }],
  'id+~': [{ label: 'id ~ 1234', category: '' }],
  'id+~ ': [{ label: 'id ~ 1234', category: '' }],
};

export const AutoCompleteProps = {
  controller,
  searchQuery,
  status,
  results,
  url,
  error,
  id,
  disabled,
};

export const AutoCompletePropsWithData = {
  ...AutoCompleteProps,
  error: undefined,
  results: API['name+%3D'],
};

export const initialState = {
  controller: null,
  error: null,
  results: [],
  searchQuery: '',
  status: null,
  trigger: null,
  isErrorVisible: false,
  id,
  disabled,
  url,
};

export const initialValues = {
  searchQuery,
  controller,
  trigger: TRIGGERS.COMPONENT_DID_MOUNT,
  status: STATUS.RESOLVED,
  error,
  isErrorVisible: !!error,
  id,
  disabled,
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
  results,
  status: STATUS.RESOLVED,
  id,
};

export const failure = {
  error,
  isErrorVisible,
  results: [],
  status: STATUS.ERROR,
  id,
};

export const disabledChange = {
  disabled: true,
  id,
};

export const controllerChange = {
  controller,
  url,
  trigger,
  id,
};

export const reset = {
  ...initialState,
  trigger: TRIGGERS.RESET,
  id,
};

