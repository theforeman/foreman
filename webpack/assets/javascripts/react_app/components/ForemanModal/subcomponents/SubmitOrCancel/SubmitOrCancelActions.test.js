import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';

import API from '../../../../redux/API/API';

import {
  SET_MODAL_START_SUBMITTING,
  SET_MODAL_STOP_SUBMITTING,
} from '../../ForemanModalConstants';

import { submitModal } from './SubmitOrCancelActions';

const middlewares = [thunk];
const mockStore = configureMockStore(middlewares);

jest.mock('../../../../redux/API/API');

const id = 'modelTestModal';

const handlerMocks = () => ({
  id,
  onSuccess: jest.fn(),
  closeFn: jest.fn(),
  getErrorMsg: jest.fn(),
});

const store = mockStore({
  foremanModals: {
    [id]: {
      isOpen: false,
      isSubmitting: false,
    },
  },
});

describe('SubmitOrCancelActions test', () => {
  it('should submit with success', async () => {
    const response = { data: { message: 'success!' } };
    const mocks = handlerMocks();
    API.delete.mockImplementation(async () => response);
    store.clearActions();
    await store.dispatch(
      submitModal({
        url: 'api/tests',
        message: 'Success!',
        ...mocks,
      })
    );
    expect(store.getActions()[0].type).toBe(SET_MODAL_START_SUBMITTING);
    expect(store.getActions()[1].type).toBe(SET_MODAL_STOP_SUBMITTING);
    expect(
      store.getActions().find(action => action.type === 'toasts/addToast').payload
        .toast.type
    ).toBe('success');
    expect(mocks.onSuccess).toHaveBeenCalled();
    expect(mocks.closeFn).toHaveBeenCalled();
    expect(mocks.getErrorMsg).not.toHaveBeenCalled();
  });
  it('should submit with error', async () => {
    const error = new Error();
    error.response = {};
    store.clearActions();
    const mocks = handlerMocks();
    API.delete.mockImplementation(async () => {
      throw error;
    });
    await store.dispatch(
      submitModal({
        url: 'api/tests',
        message: 'Error!',
        ...mocks,
      })
    );
    expect(store.getActions()[0].type).toBe(SET_MODAL_START_SUBMITTING);
    expect(store.getActions()[1].type).toBe(SET_MODAL_STOP_SUBMITTING);
    expect(
      store.getActions().find(action => action.type === 'toasts/addToast').payload
        .toast.type
    ).toBe('error');
    expect(mocks.onSuccess).not.toHaveBeenCalled();
    expect(mocks.closeFn).not.toHaveBeenCalled();
    expect(mocks.getErrorMsg).toHaveBeenCalled();
  });
});
